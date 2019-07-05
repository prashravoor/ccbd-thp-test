import matplotlib.pyplot as plt
import csv
import sys
import time

if not len(sys.argv) == 2:
    print('Usage: {} <Memory usage file>'.format(sys.argv[0]))
    exit()

filename = sys.argv[1]

csv_lines = []

with open(filename) as f:
    reader = csv.reader(f, delimiter=',')
    for r in reader:
        csv_lines.append(r)
    f.close()

baseline = time.mktime(time.strptime(csv_lines[0][0]))
header = csv_lines[0]
csv_lines = csv_lines[1:]

# X-Axis is common for all
x = [] 
y_mem_ovr = []
y_cpu_ovr = []
y_mem_mdb = []
y_cpu_mdb = []
y_mem_thp = []
y_cpu_thp = [] 

for line in csv_lines:
    x.append(time.mktime(time.strptime(line[0])) - baseline)
    y_mem_ovr.append(float(line[1]))
    y_cpu_ovr.append(float(line[2]))
    y_mem_mdb.append(float(line[3]))
    y_cpu_mdb.append(float(line[4]))
    y_mem_thp.append(float(line[5]))
    y_cpu_thp.append(float(line[6]))

plt.plot(x, y_mem_ovr, label=header[1])
plt.plot(x, y_mem_mdb, label=header[3])
plt.plot(x, y_mem_thp, label=header[5])
plt.legend()
plt.xlabel('Time (s)')
plt.ylabel('Memory Usage (%)')
plt.show()

plt.plot(x, y_cpu_ovr, label=header[2])
plt.plot(x, y_cpu_mdb, label=header[4])
plt.plot(x, y_cpu_thp, label=header[6])

plt.legend()
plt.xlabel('Time (s)')
plt.ylabel('CPU Usage (%)')
plt.show()
