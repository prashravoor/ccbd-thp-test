#!/bin/bash

HOST=$HOST
dir=/home/prashanth/thp/ccbd-thp-test/benchmarking
NUM_CORES=$1
RESTART=$2
wl=c

mongo --host=$HOST < $dir/monitoring/stats.mdb 2>&1 > $dir/monitoring/mongo_stats_$wl
echo $RESTART
if [ -z $RESTART ]; then
# Restart Server, and flush all caches
    echo Stopping the MongoDB server...
    db_pid=`ps -ef | grep mongod_thp.conf | grep -v numactl | grep -v grep | awk '{print $2'}`
    if [ -z $db_pid ]; then
        echo "No server instance found!"
    else
        /usr/bin/mongod --config /etc/mongod_thp.conf --shutdown
        echo Stopped Mongodb process $db_pid
        sleep 10
    fi

    echo Clearing caches...

    echo 1 > /proc/sys/vm/drop_caches
    echo 2 > /proc/sys/vm/drop_caches
    echo 3 > /proc/sys/vm/drop_caches

    sleep 5
    $dir/enable_all_cpus.sh
else
    echo "Not restarting the server..."
fi

python3 $dir/get_vmstat_thp_end.py $dir/monitoring/thp_stats_start_$wl.json $dir/monitoring/thp_stats_$wl.json $wl
