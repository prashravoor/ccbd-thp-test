#!/bin/bash

TIME=900 # 10 minutes
TABLES=20
TABLE_SIZE=100000
THREADS=256

run_bench()
{
    sysbench $1 --db-driver=mysql --mysql-user=prash --mysql-db=dbtest --mysql-password=Admin!23 \
        --tables=$TABLES --table-size=$TABLE_SIZE prepare
    echo 'Prepare step complete, starting to run the workload'

    python3 monitoring/monitor_khugepaged_mysql.py &
    mon_pid=$!
    log_name=memusage_sql_thp
    
    sysbench $1 --threads=$THREADS --percentile=99 --db-driver=mysql --mysql-user=prash \
        --mysql-db=dbtest --mysql-password=Admin!23 --report-interval=10 --time=$TIME run | tee logs/wl_$1".log"
    
    if [ $mon_pid -gt 0 ]; then
        kill $mon_pid
        echo 'Saved monitor log to ' monitoring/$log_name"_wl_"$1.csv
        mv $log_name.csv monitoring/$log_name"_wl_"$1.csv
    fi

    echo 'Cleaning up...'
    sysbench $1 --tables=$TABLES --db-driver=mysql --mysql-user=prash --mysql-db=dbtest --mysql-password=Admin!23 cleanup
}

for i in oltp_insert oltp_delete oltp_read_only oltp_read_write oltp_update_index oltp_update_non_index oltp_write_only; do
    run_bench $i
done
