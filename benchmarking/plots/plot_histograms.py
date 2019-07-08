import json
import math
import matplotlib.pyplot as plt
from matplotlib import gridspec
import sys
import os

if not len(sys.argv) == 3:
    print('Usage: {} <Workload Suffix (a-f|r> <log directory>'.format(sys.argv[0]))
    exit()

wl = sys.argv[1]
path = sys.argv[2]
filename_prefix = 'json_'
thp_prefix = 'thp'
filename_suffix = '.json'

filename_reg = '{}/{}{}{}'.format(path, filename_prefix,wl,filename_suffix)
filename_thp = '{}/{}{}_{}{}'.format(path, filename_prefix,wl,thp_prefix,filename_suffix)

data = {}
thp_data = {}

with open(filename_reg) as f:
    data = json.load(f)
    f.close()

with open(filename_thp) as f:
    thp_data = json.load(f)
    f.close()

def plot_metric(fig, json_data, metric_name, thp=False):
    metric_data = list(filter(lambda x: (x['measurement'].isdigit() and x['metric'] == metric_name), (json_data)))
    if len(metric_data) > 0:
        x = []
        for i in metric_data:
            x.append(float(i['value'])/1000.0)

        label = metric_name
        if thp:
            label = '{} using THP'.format(metric_name)

        fig.hist(x, label=label, histtype='step', bins=20)
        return True
    return False


metrics = ['READ', 'INSERT', 'READ-MODIFY-WRITE', 'SCAN', 'UPDATE']
N = len(metrics)
cols = 2 
rows = int(math.ceil(N/cols))

# gs = gridspec.GridSpec(rows,cols)
gs = gridspec.GridSpec(2, 2)

fig = plt.figure()

i = 0
for m in metrics:
    fig1 = fig.add_subplot(gs[i])
    if plot_metric(fig1, data, m):
        plot_metric(fig1, thp_data, m, thp=True)
        fig1.set_xlabel('Average latency (ms)')
        fig1.set_ylabel('Counts')
        fig1.legend()
        i += 1


fig.tight_layout()
plt.show()
