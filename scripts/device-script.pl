#!/usr/bin/env perl

open(my $cfg, '.config') or die ('Open config failed');
my $device;

while (<$cfg>) {
  if (/^(CONFIG_DEVICE_\w*)=y$/) {
    $device = $1;
    break;
  }
}

die ('No device configured') unless $device;

while (<'devices/*/device.in'>) {
  my $filename = $_;
  open(my $file, $filename) or die("Open $filename failed");
  while (<$file>) {
    if (/^ConfigName: (.*)$/) {
      if ($1 eq $device) {
        $filename =~ s/device\.in$/device.script/;
        my @cmd = (
          $filename,
          @ARGV
        );
        exit(system(@cmd));
      }
    }
  }
}
