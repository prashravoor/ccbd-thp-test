import os
import sys
import json

args = sys.argv
if len(args) < 2:
    print("At least 1 file needed")
    exit()

def isin(word, words):
    for w in words:
        if w in word:
            return True
    return False

first=True
toprint = ['thp', 'fault', 'swp', 'swap']
for arg in args[1:]:
    with open(arg) as f:
        mapping = json.load(f)

    #print("File: {}".format(arg))

    if first:
        first = False
        print(','.join(['Filename'] + [x for x in mapping if isin(x, toprint)]))


    print(','.join([os.path.basename(arg)] + [str(v) for k,v in mapping.items() if isin(k, toprint)]))
