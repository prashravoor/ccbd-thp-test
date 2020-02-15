#!/bin/bash

# Workload run order got from: https://github.com/brianfrankcooper/YCSB/wiki/Core-Workloads 

DIR=/home/prashanth/thp/ccbd-thp-test/benchmarking
export HOST=$HOST

run_workload_restart()
{
    wl=$1
    num_cores=$2
    if [ ! -z $2 ] && [ $2 == 'clean' ]; then
        clean=$2
        num_cores=$3
    else
	clean=
    fi

    echo $num_cores
    if [ -z $num_cores ]; then
        echo No cores
        exit
    fi
    ssh root@$HOST "nohup $DIR/start_record_cores.sh $num_cores restart >> $DIR/monitoring/start_record_log 2>&1"
    ./test_workload.sh $wl $clean $thp
    ssh root@$HOST "$DIR/stop_record_cores.sh $num_cores >> $DIR/monitoring/stop_record_log 2>&1"
    cwd=`pwd`
    cd $DIR/logs/hdr
    for f in *.hdr; do
	if [ -e "$f" ]; then
	# Use .hd instead of .hdr to avoid recursive expansion of files from previous workloads
	    mv $f ${f%.*}"_"$wl".hdr"
   	fi
    done
    cd $cwd
	./delete_logs_cores.sh $wl $num_cores
}


run_workload()
{
    wl=$1
    num_cores=$2
    if [ ! -z $2 ] && [ $2 == 'clean' ]; then
        clean=$2
        num_cores=$3
    else
	clean=
    fi

    echo $num_cores
    if [ -z $num_cores ]; then
        echo No cores
        exit
    fi
    ssh root@$HOST "nohup $DIR/start_record_cores.sh $num_cores >> $DIR/monitoring/start_record_log 2>&1"
    ./test_workload.sh $wl $clean $thp
    ssh root@$HOST "$DIR/stop_record_cores.sh $num_cores restart >> $DIR/monitoring/stop_record_log 2>&1"
    cwd=`pwd`
    cd $DIR/logs/hdr
    for f in *.hdr; do
	if [ -e "$f" ]; then
	# Use .hd instead of .hdr to avoid recursive expansion of files from previous workloads
	    mv $f ${f%.*}"_"$wl".hdr"
   	fi
    done
    cd $cwd
	./delete_logs_cores.sh $wl"_warmup_" $num_cores
}

run_test()
{
	# Run WL A - Write Heavy, 50% read, 50% writes
	echo 
	echo 'Running Workload A'
	# sshpass -p$ROOT_PASSWD ssh -tt root@localhost << EOF
	# $(typeset -f run_workload)
	#run_workload a clean $1
	# EOF

	# Run WL B - Read Heavy, 95% read, 5% writes
	echo
	echo 'Running Workload B'
	#run_workload b $1
	# Run WL C - Read Only
	echo
	echo 'Running Workload C'
	#run_workload c clean $1 $2
	run_workload c $1 $2
	run_workload_restart c $1 $2

	# Run WL R - Read Only, Random Reads
	echo
	echo 'Running Workload R'
	#run_workload r $1

	# Run WL F - Read-Modify-Write
	echo
	echo 'Running Workload F'
	#run_workload f $1

	# Run WL D - Always read latest records
	echo
	echo 'Running Workload D'
	#run_workload d $1
	#run_workload d $1
	#run_workload d $1

	# Run WL D - Read in short ranges of records rather than single
	echo
	echo 'Running Workload E'
	#run_workload e clean $1

	# Change back all .hd files to .hdr
	#cwd=`pwd`
	#cd logs/hdr
	#for f in *.hd; do
	#    mv $f ${f%.*}".hdr"
	#done
	#cd $cwd
}

run_test $1 2
run_test $1 4
run_test $1 6
run_test $1 8
run_test $1 12
run_test $1 16
run_test $1 24
run_test $1 32

