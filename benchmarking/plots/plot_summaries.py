import json
import math
import matplotlib.pyplot as plt
from matplotlib import gridspec
import sys
import os
import numpy as np

if not len(sys.argv) == 2:
    print('Usage: {} <log directory>'.format(sys.argv[0]))
    exit()

def get_filenames(wl):
    path = sys.argv[1]
    filename_prefix = 'json_'
    thp_prefix = 'thp'
    filename_suffix = '.json'

    filename_reg = '{}/{}{}{}'.format(path, filename_prefix,wl,filename_suffix)
    filename_thp = '{}/{}{}_{}{}'.format(path, filename_prefix,wl,thp_prefix,filename_suffix)

    return filename_reg,filename_thp

# workloads = ['a','b','c','d','e','f','r']
workloads = ['a','b','c','d','e','f']

times_reg = []
times_thp = []

x = np.arange(len(workloads))
for wl in workloads:
    data = {}
    thp_data = {}
    filename_reg, filename_thp = get_filenames(wl)
    with open(filename_reg) as f:
        data = json.load(f)
        f.close()

    with open(filename_thp) as f:
        thp_data = json.load(f)
        f.close()

    metrics = 'OVERALL'
    # measurement = 'RunTime(ms)'
    measurement = 'Throughput(ops/sec)'

    tmp = list(filter(lambda x: (x['metric'] == metrics and x['measurement'] == measurement), (data)))
    if len(tmp) > 0:
        # times_reg.append(float(tmp[0]['value'])/1000.0)
        times_reg.append(float(tmp[0]['value']))
    else:
        times_reg.append(0)

    tmp = list(filter(lambda x: (x['metric'] == metrics and x['measurement'] == measurement), (thp_data)))
    if len(tmp) > 0:
        # times_thp.append(float(tmp[0]['value'])/1000.0)
        times_thp.append(float(tmp[0]['value']))
    else:
        times_thp.append(0)


width=.25
plt.bar(x - width/2, times_reg, label='Regular Pages', width=width)
plt.bar(x + width/2, times_thp, label='THP Enabled', width=width)
plt.ylabel(measurement)
plt.xlabel('Workload Name')
plt.xticks(x.tolist(), workloads)
plt.legend()
plt.title('Measured over {} operations on MongoDB, with record size {}, database contains {} records'.format('1 Million', '1KB', '2 Million'))
plt.show()
