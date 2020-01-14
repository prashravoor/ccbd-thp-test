import os
import json
import sys

args = sys.argv
if len(args) < 2:
    print('Filename(s) required')
    exit()

files = args[1:]

for file in files:
    with open(file) as f:
        values = json.load(f)
        print('File: {}'.format(file))
        print('Metric\tMeasurement\tValue')
        for v in values:
            if v['metric'] in ['READ', 'INSERT', 'UPDATE', 'SCAN', 'READ-MODIFY-WRITE'] or v['measurement'] == 'Throughput(ops/sec)':
                print('{}\t{}\t{}'.format(v['metric'], v['measurement'], v['value']))
        print()
