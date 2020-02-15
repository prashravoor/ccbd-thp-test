#!/bin/bash

for ((i=8;i<=15;++i)); do
    #if [[ $i -lt 16 ]] || [[ $i -gt 19 ]]; then
        echo 0 > /sys/devices/system/cpu/cpu$i/online
    #fi
done 

for ((i=24;i<=31;++i)); do
    #if [[ $i -lt 16 ]] || [[ $i -gt 19 ]]; then
        echo 0 > /sys/devices/system/cpu/cpu$i/online
    #fi
done 
