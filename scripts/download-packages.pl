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
    if (!-d "dl/$filename.git") {
      print "==> Creating local repository $filename\n";
      @git = ("git", "init", "--bare", "-b", "__dummy", "dl/$filename.git");
      system(@git) == 0 or die("===> git init failed\n");
    }
    @git = ("git", "-C", "dl/$filename.git", "config", "advice.detachedHead", "false");
    system(@git);
    print "==> Setting up the remote\n";
    @git = ("git", "-C", "dl/$filename.git", "remote", "rm", "origin");
    system(@git);
    @git = ("git", "-C", "dl/$filename.git", "remote", "add", "origin", $src);
    system(@git) == 0 or die("===> could not add git remote\n");
    print "==> Updating repository for $filename\n";
    @git = ("git", "-C", "dl/$filename.git", "fetch", "origin");
    system(@git) == 0 or die("===> git fetch failed\n");
    print "==> Checking out repository at $at\n";
    mkdir "pkg-src";
    mkdir "pkg-src/$filename"; # Failures ignored
    @git = ("git", "-C", "dl/$filename.git", "--work-tree", "../../pkg-src/$filename/", "checkout", "origin/$at");
    system(@git) == 0 or die("===> git checkout failed\n");
  }
}
