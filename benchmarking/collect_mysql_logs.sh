#!/bin/bash

HOST=
DATE=$(date +"%d%m%Y%H%M")
scp $HOST:/home/student1/thp/ccbd-thp-test/benchmarking/monitoring/\{memusage_*,perf.data_*\} monitoring
tar -cf logs/backups/mysql_run_logs_$DATE".tgz" logs/wl_oltp_* monitoring/memusage_* monitoring/perf.data_*

rm logs/wl_oltp_*
rm monitoring/memusage_*
rm monitoring/perf.data_*
