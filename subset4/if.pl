#!/usr/bin/perl -w

$number = <STDIN>;
if ($number >= 0 || $number <= 10) {
    if ($number % 2 == 0) {
        print "Even\n";
    } else {
        print "Odd\n";
    }
}
print "Bye\n";


