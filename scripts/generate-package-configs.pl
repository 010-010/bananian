#!/usr/bin/env perl

my @base = ();

while (<packages/metadata/*>) {
  my $filename = $_;
  open(my $pkg, $filename) or die("Open $filename failed");
  $filename =~ s/metadata/descriptions/;
  open(my $desc, $filename) or die ("Open $filename failed");
  my @deps = ();
  my $name, $config, $prio, $src;
  while (<$pkg>) {
    if (/^DisplayName: (.*)$/) {
      $name = $1;
    } elsif (/^ConfigName: (.*)$/) {
      $config = $1;
    } elsif (/^Priority: (.*)$/) {
      $prio = $1;
    } elsif (/^Source: (.*)$/) {
      $src = $1;
      $src =~ s/#([^#]*)$/ (at $1)/;
    } elsif (/^Dependency: (.*)$/) {
      push @deps, $1;
    }
  }

  unless ($config) {
    $filename =~ s/description/metadata/;
    die("$filename contains no ConfigName");
  }

  print "config $config\n";
  print "  bool \"$name\"\n";
  for (@deps) {
    print "  select $_\n";
  }
  if ($prio eq 'standard') {
    print "  default y\n";
  } elsif ($prio eq 'required') {
    push @base, $config;
  }
  print "  help\n";
  while (<$desc>) {
    s/^/    /;
    print;
  }
  print "    Source: $src\n";
  print "\n";
}

if (@base) {
  my $config_base = join(' ', @base);
  print "config CONFIG_PKG_BASE\n";
  print "  bool\n";
  print "  default y\n";
  print "  select $config_base\n";
}
