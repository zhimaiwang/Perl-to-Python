#!/usr/bin/perl

$a = 0;

if ($a >0 || $a < 10) {
    print "$a\n";
}

if ($a > 0 or $a < 10) {
    print "$a\n";
}

if (!$a) {
    print "0\n"
}

if (not $a) {
    print "1\n"
}
