import os
import sys

def human_readable(num):
    suffix = 'BKMG'
    i = 0
    rem = float(num)
    while rem > 999 and i < 3:
        rem /= 1000.
        i += 1
    
    return '{}{}'.format(int(rem), suffix[i])

args = sys.argv
if len(args) < 2:
    print('File name needed!')
    exit(1)

with open(args[1]) as f:
    props = {x.split('=')[0].strip() : x.split('=')[1].strip() for x in f.readlines()}

rec = '1K'
if 'recordcount' in props:
    rec = human_readable(int(props['recordcount']))

op = '2M'
if 'operationcount' in props:
    op = human_readable(int(props['operationcount']))

thr = '16'
if 'threadcount' in props:
    thr = int(props['threadcount'])

fc = 10
if 'fieldcount' in props:
    fc = int(props['fieldcount'])

print(rec, op, thr, fc)
