#!/bin/bash

db_pid=`ps -ef | grep mongod_thp.conf | grep -v numactl | grep -v grep | awk '{print $2'}`
if [ -z $db_pid ]; then
    echo "No server instance found!"
else
    kill $db_pid
    sleep 10
fi

echo Clearing caches...

echo 1 > /proc/sys/vm/drop_caches
echo 2 > /proc/sys/vm/drop_caches
echo 3 > /proc/sys/vm/drop_caches

sleep 5

echo always > /sys/kernel/mm/transparent_hugepage/enabled
echo defer > /sys/kernel/mm/transparent_hugepage/defrag


nohup numactl --interleave=all /usr/bin/mongod --config /etc/mongod_thp.conf & disown
sleep 5
echo Server started..
