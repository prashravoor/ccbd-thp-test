#!/bin/bash

if [ -z $1 ]; then
    echo Input file missing
    exit
fi

if [ -z $2 ]; then
    echo Output file missing
    exit
fi

perf script -i $1 > /tmp/perf_file
python3 create_perf_summary.py /tmp/perf_file $2
rm /tmp/perf_file
