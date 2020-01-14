#!/bin/bash

wl=$1
log_name=memusage_mdb_thp
mon_pid=`ps -ef | grep monitor_khugepaged | grep -v grep | awk '{print $2'}`
stp_pid=`ps -ef | grep pfaults.stp | grep -v grep | awk '{print $2'}`
dir=/home/prashanth/thp/ccbd-thp-test/benchmarking

if [ ! -z $stp_pid ]; then
	kill $stp_pid
    echo Killed Stap process $stp_pid
fi

if [ ! -z $mon_pid ]; then
	#kill $mon_pid
    /usr/bin/mongod --config /etc/mongod_thp.conf --shutdown

    echo Killed Mongodb Process $mon_pid
# Save monitoring file
	mv $log_name.csv $dir/monitoring/$log_name"_wl_"$wl.csv
	echo 'Saved monitor log to ' $dir/monitoring/$log_name"_wl_"$wl.csv
fi

perf_pid=`ps -ef | grep perf | grep -v grep | awk '{print $2}'`
if [ ! -z $perf_pid ]; then
	kill $perf_pid
    echo Killed Perf Process $perf_pid
	#mv perf.data"_"$wl $dir/monitoring
fi

python3 $dir/get_vmstat_thp_end.py $dir/monitoring/thp_stats_start_$wl.json $dir/monitoring/thp_stats_$wl.json $wl

# Restart Server, and flush all caches
echo Restarting the MongoDB server...
db_pid=`ps -ef | grep mongod_thp.conf | grep -v numactl | grep -v grep | awk '{print $2'}`
if [ -z $db_pid ]; then
    echo "No server instance found!"
else
    kill $db_pid
    echo Stopped Mongodb process $db_pid
    sleep 10
fi

echo Clearing caches...

echo 1 > /proc/sys/vm/drop_caches
echo 2 > /proc/sys/vm/drop_caches
echo 3 > /proc/sys/vm/drop_caches

sleep 5

nohup numactl --interleave=all /usr/bin/mongod --config /etc/mongod_thp.conf & disown
sleep 5

db_pid=`ps -ef | grep mongod_thp.conf | grep -v numactl | grep -v grep | awk '{print $2'}`
echo Server started, new process id $db_pid
