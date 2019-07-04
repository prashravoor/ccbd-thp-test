#!/bin/bash

# Workload run order got from: https://github.com/brianfrankcooper/YCSB/wiki/Core-Workloads 

run_workload()
{
    mon_pid=0
    wl=$1
    if [ ! -z $2 ] && [ $2 == 'monitor' ]; then
        echo 'Starting to monitor khugepaged for WL ' $wl
        python3 monitoring/monitor_khugepaged.py &
        mon_pid=$!
        clean=$3
    else
        clean=$2
    fi

    ./test_workload.sh $wl $clean
    
    if [ $mon_pid -gt 0 ]; then
        kill $mon_pid
        # Save monitoring file
        echo 'Saved monitor log to ' monitoring/khugepaged_log_wl_$wl
        mv khugepaged_log monitoring/khugepaged_log_wl_$wl
    fi
}


# Run WL A - Write Heavy, 50% read, 50% writes
echo 
echo 'Running Workload A'
run_workload a $1 clean

# Run WL B - Read Heavy, 95% read, 5% writes
echo
echo 'Running Workload B'
run_workload b $1

# Run WL C - Read Only
echo
echo 'Running Workload C'
run_workload c $1

# Run WL F - Read-Modify-Write
echo
echo 'Running Workload F'
run_workload f $1

# Run WL D - Always read latest records
echo
echo 'Running Workload D'
run_workload d $1

# Run WL D - Read in short ranges of records rather than single
echo
echo 'Running Workload E'
run_workload e $1 clean


