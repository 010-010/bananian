#!/usr/bin/env perl

open(my $cfg, '.config') or die ('Open config failed');
my %enabled = ();

while (<$cfg>) {
  if (/^(\w*)=y$/) {
    $enabled{$1} = 1;
  }
}


while (<packages/metadata/*>) {
  my $filename = $_;
  open(my $pkg, $filename) or die("Open $filename failed");
  my @files = ();
  my $config, $src, $at = 'HEAD', $disabled = 0;
  my $pbp = "https://affenull2345.gitlab.io/bananian/packages-latest/";
  while (<$pkg>) {
    if (/^ConfigName: (.*)$/) {
      $config = $1;
      unless ($enabled{$config}) {
        $disabled = 1;
        last;
      }
    } elsif (/^Source: (.*)$/) {
      $src = $1;
      $at = $1;
      $src =~ s/#([^#]*)$//;
      if (grep { /^.*#/ } $at) {
        $at =~ s/^.*#//;
      } else {
        $at = 'HEAD';
      }
    } elsif (/^File: (.*)$/) {
      push @files, $1;
    } elsif (/^PrebuiltPath: (.*)$/) {
      $pbp = $1;
    }
  }

  if ($disabled) {
    next;
  }

  unless ($config) {
    die("$filename contains no ConfigName");
  }
  unless ($src) {
    die("$filename contains no Source");
  }

  $filename =~ s/packages\/metadata\///;

  if ($enabled{"${config}_DOWNLOAD"}) {
    print "==> Downloading prebuilt files for $filename\n";
    for (@files) {
      my @wget = ("wget", "-c", $pbp . $_);
      system(@wget) == 0 or die("===> Failed to download $_\n");
    }
  } else {
    my @git;
    if (!-d "$filename.git") {
      print "==> Cloning $src into $filename\n";
      @git = ("git", "clone", "--bare", $src, "$filename.git");
      system(@git) == 0 or die("===> git clone failed\n");
    }
    print "==> Updating repository for $filename\n";
    @git = ("git", "-C", "$filename.git", "fetch", "origin");
    system(@git) == 0 or die("===> git fetch failed\n");
    print "==> Checking out repository at $at\n";
    mkdir $filename; # Failures ignored
    @git = ("git", "-C", "$filename.git", "--work-tree", "../$filename/", "checkout", $at);
    system(@git) == 0 or die("===> git checkout failed\n");
  }
}
