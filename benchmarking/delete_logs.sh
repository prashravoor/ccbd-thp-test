#! /bin/bash

WL_PROFILE=lg_wl_hist
HOST=$HOST
SAVE=$2
if [ -z $SAVE ]; then
    SAVE="save"
fi

dir=/home/prashanth/thp/ccbd-thp-test/benchmarking/monitoring/
DATE=$(date +"%d%m%Y%H%M")
scp root@$HOST:$dir/\{memusage_*,perf.data_*,frag_*,thp_stats_*,pfaults_*,mongopid,mongo_stats_*\} monitoring
ssh -t root@$HOST "rm $dir/memusage_*"
ssh -t root@$HOST "rm $dir/perf.data_*"
ssh -t root@$HOST "rm $dir/frag_*"
ssh -t root@$HOST "rm $dir/thp_stats_*"
ssh -t root@$HOST "rm $dir/pfaults_*"
ssh -t root@$HOST "rm $dir/mongopid"
ssh -t root@$HOST "rm $dir/mongo_stats_*"

ls logs/*_thp.json 2> /dev/null
if [ $? -eq 0 ]; then
    thp="thp"
else
    thp="reg"
fi

res=`python3 gen_file_name.py $WL_PROFILE`
rec=`echo $res | awk '{print $1}'`
ops=`echo $res | awk '{print $2}'`
thr=`echo $res | awk '{print $3}'`
fcn=`echo $res | awk '{print $4}'`

if [ -z $1 ]; then
	tarball=logs/backups/wl_run_logs_"$DATE"_"$thp"_"$rec"_rec_"$ops"_ops_"$thr"_threads_"$fcn"_fc.tgz
else
	tarball=logs/backups/wl_run_logs_"$DATE"_"$thp"_wl_"$1"_"$rec"_rec_"$ops"_ops_"$thr"_threads_"$fcn"_fc.tgz
fi

if [ $SAVE == "save" ]; then
    tar -caf $tarball $WL_PROFILE logs/wl_* logs/errors_* logs/json_* monitoring/memusage_* logs/hdr/*.hdr monitoring/perf.data_* monitoring/frag_* monitoring/thp_stats_* monitoring/pfaults_* monitoring/mongopid monitoring/mongo_stats_*
fi
# tar -cf logs/backups/errors_logs_$DATE.tgz logs/errors_*
# tar -cf logs/backups/json_logs_$DATE.tgz $WL_PROFILE logs/json_*
# tar -cf logs/backups/memusage_logs_$DATE.tgz $WL_PROFILE monitoring/memusage_*

rm logs/errors_*
rm logs/json_*
rm logs/wl_*
rm logs/hdr/*.hdr


rm monitoring/memusage_*
rm monitoring/perf.data_*
rm monitoring/frag_*
rm monitoring/thp_stats_*
rm monitoring/pfaults_*
rm monitoring/mongopid
rm monitoring/mongo_stats_*
