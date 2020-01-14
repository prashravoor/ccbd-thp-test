import json
import sys

args = sys.argv

if not len(args) == 2:
    print('Missing output filename')
    exit()

filename = args[1]
with open('/proc/vmstat') as f:
    stats = {x.split()[0].strip() : int(x.split()[1].strip()) for x in f.readlines() if 'thp' in x or 'trans' in x or 'pg' in x}

with open(filename, 'w') as f:
    json.dump(stats, f)
