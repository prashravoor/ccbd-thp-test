#!/bin/bash

YCSB_BASE=~/YCSB/ycsb-jdbc-binding-0.15.0

YCSB=$YCSB_BASE/bin/ycsb
WORKLOADS=$YCSB_BASE/workloads
WL=lg_wl_hist

wl='a'

if [ -z $1 ]; then 
    echo 'Usage: $0 <Workload Suffix (a-f|r)> [clean]'
    exit
fi

wl=$1
wl_name=$WORKLOADS/workload$wl
outfile=logs/json_$wl.json

# Ensure mysql is up and running
pid=$(ps -ef | grep "mysqld" | grep -v "grep" | wc -l)

if [ $pid == 0 ]; then
    echo 'Starting Mysql Service'
    systemctl start mysql
    sleep 5
fi

if [ ! -z $2 ] && [ $2 == 'clean' ]; then
    echo 'Cleaning and recreating DB'
    export CLASSPATH=$YCSB_BASE/lib/mysql-connector-java-8.0.17.jar:$YCSB_BASE/lib/jdbc-binding-0.15.0.jar
    java com.yahoo.ycsb.db.JdbcDBCreateTable -n usertable -P db.properties
    $YCSB load jdbc -db com.yahoo.ycsb.db.JdbcDBClient -P db.properties -P $wl_name -P $WL -s 2> logs/errors_load_wl_$wl | tee logs/wl_load_$wl.txt
    if [ ! -z $3 ] && [ $3 == 'thp' ]; then
        outfile=logs/json_$wl"_thp.json"
    fi
elif [ ! -z $2 ] && [ $2 == 'thp' ]; then
    outfile=logs/json_$wl"_thp.json"
fi

$YCSB run jdbc -db com.yahoo.ycsb.db.JdbcDBClient -jvm-args "-Xms1024m -Xms1024m" -P db.properties -P $wl_name -P $WL -p exportfile=$outfile -s 2> logs/errors_run_wl_$wl | tee logs/wl_$wl.run.txt

