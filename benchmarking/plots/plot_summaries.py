import json
import math
import matplotlib.pyplot as plt
from matplotlib import gridspec
import sys
import os

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

workloads = ['a','b','c','d','e','f','r']

times_reg = []
times_thp = []

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
    measurement = 'RunTime(ms)'

    tmp = list(filter(lambda x: (x['metric'] == metrics and x['measurement'] == measurement), (data)))
    times_reg.append(float(tmp[0]['value'])/1000.0)

    tmp = list(filter(lambda x: (x['metric'] == metrics and x['measurement'] == measurement), (thp_data)))
    times_thp.append(float(tmp[0]['value'])/1000.0)


plt.plot(workloads, times_reg, label='Regular Pages')
plt.plot(workloads, times_thp, label='THP Enabled')
plt.ylabel('Total Runtime (sec)')
plt.xlabel('Workload Name')
plt.legend()
plt.show()
