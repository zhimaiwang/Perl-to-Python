#!/usr/local/bin/python -u
import sys
print("Enter a number: ")
a = sys.stdin.readline()
a  = float(a )
if a < 0:
    print("negative")
elif a == 0:
    print("zero")
elif a < 10:
    print("small")
else:
    print("large")
