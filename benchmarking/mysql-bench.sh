#!/bin/bash

TIME=900 # 10 minutes
TABLES=20
TABLE_SIZE=100000
THREADS=256
PASSWORD=
USER=prash

run_bench()
{
    sysbench $1 --db-driver=mysql --mysql-user=$USER --mysql-db=dbtest --mysql-password=$PASSWORD \
        --tables=$TABLES --table-size=$TABLE_SIZE prepare
    echo 'Prepare step complete, starting to run the workload'

    python3 monitoring/monitor_khugepaged_mysql.py &
    mon_pid=$!
    log_name=memusage_sql_thp
    
    sysbench $1 --threads=$THREADS --percentile=99 --db-driver=mysql --mysql-user=$USER \
        --mysql-db=dbtest --mysql-password=$PASSWORD --report-interval=10 --time=$TIME run | tee logs/wl_$1".log"
    
    if [ $mon_pid -gt 0 ]; then
        kill $mon_pid
        echo 'Saved monitor log to ' monitoring/$log_name"_wl_"$1.csv
        mv $log_name.csv monitoring/$log_name"_wl_"$1.csv
    fi

    echo 'Cleaning up...'
    sysbench $1 --tables=$TABLES --db-driver=mysql --mysql-user=$USER --mysql-db=dbtest --mysql-password=$PASSWORD cleanup
}

run_workload()
{
    mon_pid=0
    wl=$1
    thp=$3
    log_name=memusage_sql
    if [ ! -z $2 ] && [ $2 == 'monitor' ]; then
        echo 'Starting to monitor khugepaged for WL ' $wl
        python3 monitoring/monitor_khugepaged_mysql.py &
        mon_pid=$!
        clean=$3
        thp=$4
    elif [ ! -z $2 ] && [ $2 == 'clean' ]; then
        clean=$2
        thp=$3
    else
        thp=$2
    fi

    sql_pid=`ps -ef | grep mysqld | grep -v grep | awk '{print $2}'`
    perf record -F 999 -p $sql_pid -o perf.data"_"$wl \
        -e page-faults,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores,iTLB-load-misses,iTLB-loads &
    perf_pid=$!

    ./mysql_test_workload.sh $wl $clean $thp
    
    if [ $mon_pid -gt 0 ]; then
        kill $mon_pid
        # Save monitoring file
        echo 'Saved monitor log to ' monitoring/$log_name"_wl_"$wl.csv
        mv $log_name.csv monitoring/$log_name"_"$thp"_wl_"$wl.csv
    fi

    kill $perf_pid
    mv perf.data"_"$wl monitoring

    cwd=`pwd`
    cd logs/hdr
    for f in *.hdr; do
        if [ -e "$f" ]; then
# Use .hd instead of .hdr to avoid recursive expansion of files from previous workloads
            mv $f ${f%.*}"_"$wl".hd"
        fi
    done 
    cd $cwd
}

if [ ! -z $1 ] && [ $1 == 'ycsb' ]; then
# Run WL A - Write Heavy, 50% read, 50% writes
    echo 
    echo 'Running Workload A'
    run_workload a monitor clean $2

# Run WL B - Read Heavy, 95% read, 5% writes
    echo
    echo 'Running Workload B'
    run_workload b monitor $2

# Run WL C - Read Only
    echo
    echo 'Running Workload C'
    run_workload c monitor $2

# Run WL R - Read Only, Random Reads
    echo
    echo 'Running Workload R'
    run_workload r monitor $2

# Run WL F - Read-Modify-Write
    echo
    echo 'Running Workload F'
  run_workload f monitor $2

# Run WL D - Always read latest records
    echo
    echo 'Running Workload D'
    run_workload d monitor $2

# Run WL E - Read in short ranges of records rather than single
    echo
    echo 'Running Workload E'
    run_workload e monitor clean $2

# Change back all .hd files to .hdr
    cwd=`pwd`
    cd logs/hdr
    for f in *.hd; do
        mv $f ${f%.*}".hdr"
    done
    cd $cwd
else
    for i in oltp_insert oltp_delete oltp_read_only oltp_read_write oltp_update_index oltp_update_non_index oltp_write_only; do
        run_bench $i
    done
fi
