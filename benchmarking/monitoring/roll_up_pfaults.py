import os
import sys

args = sys.argv
if len(args) < 2:
    print("At least 1 file required")
    exit()

for arg in args[1:]:
    with open(arg) as f:
        print('{}: {}'.format(arg, sum([int(x.split(':')[6]) for x in f.readlines()])))
