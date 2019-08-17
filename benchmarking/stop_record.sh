#!/bin/bash
wl=$1
log_name=memusage_mdb_thp
mon_pid=`ps -ef | grep monitor_khugepaged | grep -v grep | awk '{print $2'}`
dir=/home/student1/thp/ccbd-thp-test/benchmarking
if [ ! -z $mon_pid ]; then
	kill $mon_pid
# Save monitoring file
	mv $log_name.csv $dir/monitoring/$log_name"_wl_"$wl.csv
	echo 'Saved monitor log to ' $dir/monitoring/$log_name"_wl_"$wl.csv
fi

perf_pid=`ps -ef | grep perf | grep -v grep | awk '{print $2}'`
if [ ! -z $perf_pid ]; then
	kill $perf_pid
	#mv perf.data"_"$wl $dir/monitoring
fi

