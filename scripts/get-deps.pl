#!/usr/bin/env perl

open(my $cfg, '.config') or die ('Open config failed');
my %enabled = ();

while (<$cfg>) {
  if (/^(\w*)=y$/) {
    $enabled{$1} = 1;
  }
}

my %depends = (), %local = (), %pdepends = ();
open(my $debpackages, $ARGV[0]) or die ('Open packages failed');

my $pkg;
while (<$debpackages>) {
  if (/^Package: (.*)$/) {
    $pkg = $1;
    $local{$pkg} = 1;
    next;
  }
  
  if (/^Provides: (.*)$/) {
    $local{$1} = 1;
  }
  elsif (/^(Pre-)?Depends: (.*)$/) {
    my @pdeps = ();
    for my $dep (split /\s*,\s*/, $2) {
      $dep =~ s/\s*[|].*$//;
      $dep =~ s/\s*[(].*[)]\s*//;
      $dep =~ s/:.*//;
      push @pdeps, $dep;
    }
    @pdepends{$pkg} = \@pdeps;
  }
}

for my $deb (<*.deb>) {
  $deb =~ s/_.*$//; # Only keep the package name
  for my $dep (@{$pdepends{$deb}}) {
    $depends{$dep} = 1;
  }
}

print join(',', grep { !exists $local{$_} } sort keys %depends);
print "\n";
