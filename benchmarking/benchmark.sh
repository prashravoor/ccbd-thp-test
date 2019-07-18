#!/bin/bash

# Workload run order got from: https://github.com/brianfrankcooper/YCSB/wiki/Core-Workloads 

run_workload()
{
    mon_pid=0
    wl=$1
    thp=$3
    log_name=memusage_mdb_thp
    if [ ! -z $2 ] && [ $2 == 'monitor' ]; then
        echo 'Starting to monitor khugepaged for WL ' $wl
        python3 monitoring/monitor_khugepaged.py &
        mon_pid=$!
        clean=$3
        thp=$4
    elif [ ! -z $2 ] && [ $2 == 'clean' ]; then
        clean=$2
        thp=$3
    else
        thp=$2
    fi

    ./test_workload.sh $wl $clean $thp
    
    if [ $mon_pid -gt 0 ]; then
        kill $mon_pid
        # Save monitoring file
        echo 'Saved monitor log to ' monitoring/$log_name"_wl_"$wl.csv
        mv $log_name.csv monitoring/$log_name"_wl_"$wl.csv
    fi

    cwd=`pwd`
    cd logs/hdr
    for f in *.hdr; do
        if [ -e "$f" ]; then
# Use .hd instead of .hdr to avoid recursive expansion of files from previous workloads
            mv $f ${f%.*}"_"$wl".hd"
        fi
    done 
    cd $cwd
}


# Run WL A - Write Heavy, 50% read, 50% writes
echo 
echo 'Running Workload A'
run_workload a $1 clean $2

# Run WL B - Read Heavy, 95% read, 5% writes
echo
echo 'Running Workload B'
run_workload b $1 $2

# Run WL C - Read Only
echo
echo 'Running Workload C'
run_workload c $1 $2

# Run WL R - Read Only, Random Reads
echo
echo 'Running Workload R'
run_workload r $1 $2

# Run WL F - Read-Modify-Write
echo
echo 'Running Workload F'
run_workload f $1 $2

# Run WL D - Always read latest records
echo
echo 'Running Workload D'
run_workload d $1 $2

# Run WL D - Read in short ranges of records rather than single
echo
echo 'Running Workload E'
# run_workload e $1 clean $2

# Change back all .hd files to .hdr
cwd=`pwd`
cd logs/hdr
for f in *.hd; do
    mv $f ${f%.*}".hdr"
done
cd $cwd
