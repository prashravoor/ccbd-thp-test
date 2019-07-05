#!/bin/bash

YCSB_BASE=~/YCSB/ycsb-mongodb-binding-0.15.0

YCSB=$YCSB_BASE/bin/ycsb
WORKLOADS=$YCSB_BASE/workloads
WL=lg_wl

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
    systemctl start mongod
    sleep 5
fi

if [ ! -z $2 ] && [ $2 == 'clean' ]; then
    echo 'Cleaning and recreating DB'
    mongo < cleanup.mdb
    $YCSB load mongodb -P $wl_name -P $WL -s 2> logs/errors_load_wl_$wl | tee logs/wl_load_$wl.txt
fi

$YCSB run mongodb -P $wl_name -P $WL -p exportfile=$outfile -s 2> logs/errors_run_wl_$wl | tee logs/wl_$wl.run.txt

