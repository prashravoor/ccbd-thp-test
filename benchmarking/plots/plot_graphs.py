import json
import matplotlib.pyplot as plt
import sys
import os

if not len(sys.argv) == 2:
    print('Usage: {} <filenames to plot>'.format(sys.argv[0]))
    exit()

filename = sys.argv[1]
data = {}
with open(filename) as f:
    data = json.load(f)
    f.close()

def plot_metric(json_data, metric_name):
    metric_data = list(filter(lambda x: (x['measurement'].isdigit() and x['metric'] == metric_name), (json_data)))
    if len(metric_data) > 0:
        x = []
        y = []
        for i in metric_data:
            x.append(int(i['measurement'])/1000)
            y.append(float(i['value'])/1000.0)

        plt.plot(x,y,label=metric_name)

fname = os.path.basename(filename)
prefix = fname.split('_')[1][0].upper()

# Plot READ
plot_metric(data, 'READ')
plot_metric(data, 'READ-MODIFY-WRITE')
plot_metric(data, 'UPDATE')
plot_metric(data, 'INSERT')
plot_metric(data, 'SCAN')
# plot_metric(data, 'CLEANUP')
plt.title('Workload {}'.format(prefix))
plt.xlabel('Time (seconds)')
plt.ylabel('Average latency (ms)')
plt.legend()

plt.show()
