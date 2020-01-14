#!/bin/bash

mon_pid=0
wl=$1
thp=$3
log_name=memusage_mdb_thp
dir=/home/prashanth/thp/ccbd-thp-test/benchmarking

python3 $dir/calc_fragmentation.py > $dir/monitoring/frag_$wl
python3 $dir/monitoring/monitor_khugepaged.py &
python3 $dir/get_vmstat_thp_begin.py $dir/monitoring/thp_stats_start_$wl.json
mon_pid=$!
clean=$2
thp=$3

mongo_pid=`ps -ef | grep mongod | grep -v grep | grep -v top | grep -v numa | grep 'mongod_thp.conf' | awk '{print $2}'`
echo $mongo_pid > $dir/monitoring/mongopid

perf record -F 99 -g -a  -p $mongo_pid -o $dir/monitoring/perf.data"_"$wl \
-e page-faults,dTLB-load-misses,dTLB-loads,iTLB-load-misses,iTLB-loads &
#-e dTLB-load-misses,dTLB-loads,iTLB-load-misses,iTLB-loads &
perf_pid=$!

sleep 10
stap $dir/pfaults.stp -v --all-modules -o $dir/monitoring/pfaults_$wl -x $mongo_pid >> $dir/monitoring/stap_log 2>&1 & 
sleep 15
stap_pid=`ps -ef | grep pfaults.stp | grep -v grep | awk '{print $2}'`
echo SystemTap PID: $stap_pid, MongoDB Pid: $mongo_pid, Monitoring PID: $mon_pid, Perf PID: $perf_pid

disown -ar
