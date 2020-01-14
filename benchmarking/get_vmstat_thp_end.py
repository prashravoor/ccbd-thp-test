import os
import json
import sys

args = sys.argv

if not len(args) == 4:
    print('Usage: {} <begin file> <final output file> <WL Name>'.format(args[0]))
    exit(1)

infile = args[1]
outfile = args[2]
wl = args[3]

with open('/proc/vmstat') as f:
    stats = {x.split()[0].strip() : int(x.split()[1].strip()) for x in f.readlines() if 'thp' in x or 'trans' in x or 'pg' in x}

with open(infile) as f:
    oldstats = json.load(f)

new_stats = {k : stats[k] - oldstats[k] for k,v in stats.items()}

with open(outfile, 'w') as f:
    json.dump(new_stats, f)

os.remove(infile)
