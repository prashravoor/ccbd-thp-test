import pandas as pd
import numpy as np
import sys

args = sys.argv
if len(args) < 2:
    print('At least 1 file required')
    exit()

columns = ['Memory Used (%) Overall', 'CPU (%) Overall',' Memory Used (%) MongoDB',
           ' CPU (%) MongoDB',' Memory Used (%) khugepaged',
           ' CPU (%) khugepaged','Process HugePages (%)','Number of Huge Pages']

print('Filenames,{}'.format(','.join(args[1:])))
mins,maxs,means = {},{},{}
first = True
for column in columns:
    mins_col = []
    maxs_col = []
    means_col = []
    for file in args[1:]:
         df = pd.read_csv(file)
         mins_col.append('{:.3f}'.format(df[column].min()))
         maxs_col.append('{:.3f}'.format(df[column].max()))
         means_col.append('{:.3f}'.format(df[column].mean()))

    mins[column] = mins_col
    maxs[column] = maxs_col
    means[column] = means_col

for i in columns:

    print(','.join(['Min of {}'.format(i)] + mins[i]))

    print(','.join(['Max of {}'.format(i)] + maxs[i]))

    print(','.join(['Mean of {}'.format(i)] + means[i]))
    print()
