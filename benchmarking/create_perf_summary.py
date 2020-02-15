import sys
import json

def containsAny(string, strings):
    for s in strings:
        if s in string:
            return True
    return False

args = sys.argv
if not len(args) == 3:
    print('Usage: cmd <input file> <output file>')
    exit()

events = "L1-dcache-load-misses L1-dcache-loads L1-icache-load-misses L1-icache-loads dTLB-load-misses dTLB-loads iTLB-load-misses iTLB-loads".split()
counts = {i:0 for i in events}

with open(args[1]) as f:
    lines = f.readlines()


for l in lines:
    if containsAny(l, counts.keys()):
        parts = l.split()
        counts[parts[4][:-1]] += int(parts[3])

with open(args[2], 'w') as f:
    json.dump(counts, f)
