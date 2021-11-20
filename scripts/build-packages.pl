#!/usr/bin/env perl

open(my $cfg, '.config') or die ('Open config failed');
my %enabled = ();

while (<$cfg>) {
  if (/^(\w*)=y$/) {
    $enabled{$1} = 1;
  }
}

my %pnames = (), %pdepends = ();
my @packages = ();

while (<packages/metadata/*>) {
  my $filename = $_;
  open(my $pkg, $filename) or die("Open $filename failed");
  my $config;
  my @deps = ();
  while (<$pkg>) {
    if (/^ConfigName: (.*)$/) {
      $config = $1;
    } elsif (/^File: (.*)$/) {
      unlink $1;
    } elsif (/^Dependency: (.*)$/) {
      push @deps, $1;
    }
  }

  $filename =~ s/packages\/metadata\///;

  if ($config) {
    $pnames{$config} = $filename;
  } else {
    die("$filename contains no ConfigName");
  }

  if ($enabled{$config}) {
    @pdepends{$filename} = \@deps;
    push @packages, $filename;
  }
}

my %found = ();

for (@packages) {
  for (@{$pdepends{$_}}) {
    $_ = $pnames{$_};
  }
}

sub buildtree {
  my @result = ();
  for (@{$_[0]}) {
    my $subtree = $found{$_};
    unless ($subtree) {
      $subtree = buildtree($pdepends{$_});
      $found{$_} = $subtree;
    }
    push @result, {
      name => $_,
      deps => $subtree
    };
  }
  return \@result;
}

my $deptree = buildtree(\@packages);

my @resolved = (), %isresolved = ();

sub resolvetree {
  for(@{$_[0]}) {
    if (@{$_->{deps}}) {
      resolvetree($_->{deps});
    }
    unless ($isresolved{$_->{name}}) {
      push @resolved, $_->{name};
      $isresolved{$_->{name}} = 1;
    }
  }
}

resolvetree($deptree);

for (@resolved) {
  my @args = ("scripts/builtin-build", "pkg-src/$_");
  system(@args) == 0 or die("==> Build failed\n");
}
