#!/bin/bash

mon_pid=0
wl=$1
thp=$3
log_name=memusage_mdb_thp
dir=/home/student1/thp/ccbd-thp-test/benchmarking

python3 $dir/calc_fragmentation.py > $dir/monitoring/frag_$wl
python3 $dir/monitoring/monitor_khugepaged.py &
mon_pid=$!
clean=$2
thp=$3

mongo_pid=`ps -ef | grep mongod | grep -v grep | grep -v top | grep -v numa | grep 'mongod.conf' | awk '{print $2}'`
echo $mongo_pid

perf record -F 999 -p $mongo_pid -o $dir/monitoring/perf.data"_"$wl \
-e page-faults,dTLB-load-misses,dTLB-loads,iTLB-load-misses,iTLB-loads &
perf_pid=$!

disown -ar
