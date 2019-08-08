#!/bin/bash

DATE=$(date +"%d%m%Y%H%M")
tar -cf logs/backups/mysql_run_logs_$DATE".tgz" logs/wl_oltp_* monitoring/memusage_* monitoring/perf.data_*

rm logs/wl_oltp_*
rm monitoring/memusage_*
rm monitoring/perf.data_*
