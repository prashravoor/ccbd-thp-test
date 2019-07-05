#! /bin/bash

WL_PROFILE=lg_wl

DATE=$(date +"%d%m%Y%H%M")
tar -cf logs/backups/wl_run_logs_$DATE.tgz $WL_PROFILE logs/wl_*
tar -cf logs/backups/errors_logs_$DATE.tgz logs/errors_*
tar -cf logs/backups/json_logs_$DATE.tgz $WL_PROFILE logs/json_*
tar -cf logs/backups/memusage_logs_$DATE.tgz $WL_PROFILE monitoring/memusage_*

rm logs/errors_*
rm logs/json_*
rm logs/wl_*


rm monitoring/memusage_*
