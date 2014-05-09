#!/usr/bin/perl
use strict;
use warnings;

my %out;
foreach (split(/\n/, `yumdb search command_line "*install*"`)) {
    if (/command_line =.*install (.*)/) {
        $out{$_} = 1 foreach split(/ /, $1);
    }
}
foreach (sort keys %out) {
    if (!/^-/ && system("rpm -q $_ > /dev/null") == 0) {
        print "$_\n";
    }
}
