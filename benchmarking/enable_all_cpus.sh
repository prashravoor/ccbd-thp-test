#!/bin/bash

for ((i=0;i<=31;++i)); do
    #if [[ $i -lt 16 ]] || [[ $i -gt 19 ]]; then
        echo 1 > /sys/devices/system/cpu/cpu$i/online
    #fi
done 
