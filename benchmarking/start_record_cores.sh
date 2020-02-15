#!/bin/bash

num_cores=$1
RESTART=$2
wl=c

dir=/home/prashanth/thp/ccbd-thp-test/benchmarking

python3 $dir/calc_fragmentation.py > $dir/monitoring/frag_$wl
python3 $dir/get_vmstat_thp_begin.py $dir/monitoring/thp_stats_start_$wl.json
if [ -z $RESTART ]; then
    $dir/tune.sh
    $dir/disable_cpus.sh $num_cores
    nohup numactl --interleave=all /usr/bin/mongod --config /etc/mongod_thp.conf & disown

    disown -ar
    sleep 5

    db_pid=`ps -ef | grep mongod_thp.conf | grep -v numactl | grep -v grep | awk '{print $2'}`
    echo Server started, new process id $db_pid

    echo $db_pid > $dir/monitoring/mongopid
else
    echo "Server will not be restarted..."
    exit
fi


