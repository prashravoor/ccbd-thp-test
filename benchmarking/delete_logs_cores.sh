#! /bin/bash

WL_PROFILE=lg_wl_hist
HOST=$HOST
CORES=$2

if [ -z $CORES ]; then
    echo Num cores not specified...
    exit
fi

dir=/home/prashanth/thp/ccbd-thp-test/benchmarking/monitoring/
DATE=$(date +"%d%m%Y%H%M")
scp root@$HOST:$dir/\{frag_*,thp_stats_*,mongo_stats_*\} monitoring
ssh -t root@$HOST "rm $dir/frag_*"
ssh -t root@$HOST "rm $dir/thp_stats_*"
ssh -t root@$HOST "rm $dir/mongo_stats_*"

res=`python3 gen_file_name.py $WL_PROFILE`
rec=`echo $res | awk '{print $1}'`
ops=`echo $res | awk '{print $2}'`
thr=`echo $res | awk '{print $3}'`
fcn=`echo $res | awk '{print $4}'`

tarball=logs/backups/wl_run_logs_"$DATE"_"$thp"_wl_"$1"_"$rec"_rec_"$ops"_ops_"$thr"_threads_"$fcn"_fc_"$CORES"_cores.tgz

tar -caf $tarball $WL_PROFILE logs/wl_* logs/errors_* logs/json_* logs/hdr/*.hdr monitoring/frag_* monitoring/thp_stats_* monitoring/mongo_stats_* 

rm logs/errors_*
rm logs/json_*
rm logs/wl_*
rm logs/hdr/*.hdr

rm monitoring/frag_*
rm monitoring/thp_stats_*
rm monitoring/mongo_stats_*
