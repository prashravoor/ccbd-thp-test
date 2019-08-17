#!/bin/bash

# YCSB_BASE=~/YCSB/ycsb-mongodb-binding-0.15.0
YCSB_BASE=~/MongoDB_Network/YCSB

YCSB=$YCSB_BASE/bin/ycsb
WORKLOADS=$YCSB_BASE/workloads
WL=lg_wl_hist
HOST=

wl='a'

if [ -z $1 ]; then 
    echo 'Usage: $0 <Workload Suffix (a-f|r)> [clean]'
    exit
fi

wl=$1
wl_name=$WORKLOADS/workload$wl
outfile=logs/json_$wl.json

# Ensure mongo is up and running
pid=$(ps -ef | grep "mongod" | grep -v "grep" | wc -l)

if [ $pid == 0 ]; then
    echo 'Starting Mongo Service'
    # systemctl start mongod
    # sleep 5
fi

if [ ! -z $2 ] && [ $2 == 'clean' ]; then
    echo 'Cleaning and recreating DB'
    ssh -t root@$HOST "/home/student1/thp/ccbd-thp-test/benchmarking/cleanup_mongod.sh"
    $YCSB load mongodb-async -P $wl_name -P $WL -s 2> logs/errors_load_wl_$wl | tee logs/wl_load_$wl.txt
    if [ ! -z $3 ] && [ $3 == 'thp' ]; then
        outfile=logs/json_$wl"_thp.json"
    fi
elif [ ! -z $2 ] && [ $2 == 'thp' ]; then
    outfile=logs/json_$wl"_thp.json"
fi

$YCSB run mongodb-async -jvm-args "-Xms1024m -Xms1024m" -P $wl_name -P $WL -p exportfile=$outfile -s 2> logs/errors_run_wl_$wl | tee logs/wl_$wl.run.txt

