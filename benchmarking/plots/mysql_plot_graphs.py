import matplotlib.pyplot as plt
import sys
import os
import numpy as np
import csv

def get_filenames(wl):
    path = sys.argv[1]
    filename_prefix = 'wl_oltp_'
    thp_prefix = 'thp'
    thp_frag = 'thp_frag'
    filename_suffix = '.log'

    filename_reg = '{}/{}{}{}'.format(path, filename_prefix,wl,filename_suffix)
    filename_thp = '{}/{}{}_{}{}'.format(path, filename_prefix,wl,thp_prefix,filename_suffix)
    filename_frag = '{}/{}{}_{}{}'.format(path, filename_prefix,wl,thp_frag,filename_suffix)

    return filename_reg,filename_thp, filename_frag

def parse_file(f):
   lines = {}
   for line in f.readlines():
       parts = list(map(lambda x: x.strip(), 
                       line.split('         ') # Copied from file, 8 blank spaces
                       ))
       parts = list(filter(lambda x: len(x) > 0, parts)) #Remove any null strings, so there would only be 2-word tuples
       if len(parts) > 1:
           lines[parts[0][0:-1]] = parts[1] # Remove trailing ':' from all keys
   return lines
        

def extract_stats(wl_name, data):
# Tuple format: [ WL Name, Total Transactions, Total Runtime (s), Average Latency (ms), 99th Percentile latency (ms), Throughput (ops/sec) ]
    line = []
    line.append(wl)
    line.append(int(data['total']))
    line.append(float(data['total time'][0:-1])) # Removing traling 's'
    line.append(float(data['avg']))
    line.append(float(data['99th percentile']))
    line.append(float(line[1]/line[2])) # Throughput = total ops / total runtime

    return line

if not len(sys.argv) == 2 and not len(sys.argv) == 3:
    print('Usage: {} <directory name>'.format(sys.argv[0]))
    exit()

workloads = ['delete','insert','read_only','read_write','update_index','update_non_index', 'write_only']

stats_reg = []
stats_thp = []
stats_frag = []

x = np.arange(len(workloads))
for wl in workloads:
    data = {}
    thp_data = {}
    frag_data = {}
    filename_reg, filename_thp, filename_frag = get_filenames(wl)
    with open(filename_reg) as f:
        data = parse_file(f)
        f.close()

    with open(filename_thp) as f:
        thp_data = parse_file(f)
        f.close()
    
    with open(filename_frag) as f:
        frag_data = parse_file(f)
        f.close()

    stats_reg.append(extract_stats(wl, data))
    stats_thp.append(extract_stats(wl, thp_data))
    stats_frag.append(extract_stats(wl, frag_data))

if len(sys.argv) == 3 and sys.argv[2] == 'save':
    filename = 'oltp_regular.csv'
    filename_thp = 'oltp_thp.csv'
    filename_frag = 'oltp_thp_frag.csv'
    headers = ['Workload Name', 'Total Transactions', 'Total Runtime (s)', 'Average Latency (ms)', '99th Percentile Latency (ms)', 'Throughput (ops/sec)']

    with open(filename, 'w') as f:
        csv.writer(f).writerow(headers)
        csv.writer(f).writerows(stats_reg)
        f.close()

    with open(filename_thp, 'w') as f:
        csv.writer(f).writerow(headers)
        csv.writer(f).writerows(stats_thp)
        f.close()

    with open(filename_frag, 'w') as f:
        csv.writer(f).writerow(headers)
        csv.writer(f).writerows(stats_frag)
        f.close()

measurement = 'Average Latency (ms)'
measurement_index = 3
times_reg = list(map(lambda x: x[measurement_index], stats_reg))
times_thp = list(map(lambda x: x[measurement_index], stats_thp))
times_frag = list(map(lambda x: x[measurement_index], stats_frag))

width=.15
plt.bar(x - width, times_reg, label='Regular Pages', width=width)
plt.bar(x, times_thp, label='THP Enabled', width=width)
plt.bar(x + width, times_frag, label='THP Enabled (High Fragmentation)', width=width)
plt.ylabel(measurement)
plt.xlabel('Workload Name')
plt.xticks(x.tolist(), workloads)
plt.legend()
plt.title('OLTP Workloads, operations on MySQL, with {} tables, each contains {} records'.format('20', '1 Lakh'))
plt.show()
