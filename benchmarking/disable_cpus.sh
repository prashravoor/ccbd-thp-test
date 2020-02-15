#!/bin/bash

num_cores=$1
if [ -z $num_cores ]; then
    echo Invalid number of cores specified
    exit
fi

for ((i=$num_cores;i<=31;++i)); do
    #if [[ $i -lt 16 ]] || [[ $i -gt 19 ]]; then
        echo 0 > /sys/devices/system/cpu/cpu$i/online
    #fi
done 
