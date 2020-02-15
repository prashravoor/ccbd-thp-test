import sys
import json

args = sys.argv
if len(args) < 2:
    print('At least 1 file required')
    exit()

columns = "L1-dcache-load-misses L1-dcache-loads L1-icache-load-misses L1-icache-loads dTLB-load-misses dTLB-loads iTLB-load-misses iTLB-loads".split() 
rate_columns = "L1-dcache-load L1-icache-load dTLB-load iTLB-load".split()

print('Filenames,{}'.format(','.join(args[1:])))
first = True
mins = {}
rates = {}
for column in columns:
    mins_col = []
    for file in args[1:]:
         with open(file) as f:
            df = json.load(f)
         mins_col.append('{}'.format(df[column]))

    mins[column] = mins_col

for rate in rate_columns:
    loads = '{}s'.format(rate)
    misses = '{}-misses'.format(rate)

    mins['{}-Miss-Rate'.format(rate)] = ['{:.3f}'.format(float(mins[misses][x])/float(mins[loads][x])) for x in range(len(mins[misses]))]


for i in mins.keys():
    print(','.join(['{}'.format(i)] + mins[i]))
