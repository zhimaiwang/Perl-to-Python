#!/usr/local/bin/python -u
import sys

number = sys.stdin.readline()
number  = float(number )
if number >= 0 or number <= 10:
    if number % 2 == 0:
        print("Even")
    else:
        print("Odd")
print("Bye")


