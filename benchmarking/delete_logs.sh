#! /bin/bash

WL_PROFILE=lg_wl_hist
HOST=

dir=/home/student1/thp/ccbd-thp-test/benchmarking/monitoring/
DATE=$(date +"%d%m%Y%H%M")
scp root@$HOST:$dir/\{memusage_*,perf.data_*,frag_*\} monitoring
ssh -t root@$HOST "rm $dir/memusage_*"
ssh -t root@$HOST "rm $dir/perf.data_*"
ssh -t root@$HOST "rm $dir/frag_*"
tar -cf logs/backups/wl_run_logs_$DATE.tgz $WL_PROFILE logs/wl_* logs/errors_* logs/json_* monitoring/memusage_* logs/hdr/*.hdr monitoring/perf.data_* monitoring/frag_*
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
