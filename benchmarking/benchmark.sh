#!/bin/bash

# Workload run order got from: https://github.com/brianfrankcooper/YCSB/wiki/Core-Workloads 

DIR=/home/prashanth/thp/ccbd-thp-test/benchmarking
HOST=

run_workload()
{
    wl=$1
    thp=$2
    if [ ! -z $2 ] && [ $2 == 'clean' ]; then
        clean=$2
        thp=$3
    else
	clean=
    fi

    ssh -t root@$HOST "nohup $DIR/start_record.sh $wl >> $DIR/monitoring/start_record_log 2>&1"
    ./test_workload.sh $wl $clean $thp
    ssh root@$HOST "$DIR/stop_record.sh $wl >> $DIR/monitoring/stop_record_log 2>&1"
    cwd=`pwd`
    cd $DIR/logs/hdr
    for f in *.hdr; do
	if [ -e "$f" ]; then
	# Use .hd instead of .hdr to avoid recursive expansion of files from previous workloads
	    mv $f ${f%.*}"_"$wl".hdr"
   	fi
    done
    cd $cwd
	./delete_logs.sh $wl
}

run_test()
{
	# Run WL A - Write Heavy, 50% read, 50% writes
	echo 
	echo 'Running Workload A'
	# sshpass -p$ROOT_PASSWD ssh -tt root@localhost << EOF
	# $(typeset -f run_workload)
	run_workload a clean $1
	# EOF

	# Run WL B - Read Heavy, 95% read, 5% writes
	echo
	echo 'Running Workload B'
	run_workload b $1

	# Run WL C - Read Only
	echo
	echo 'Running Workload C'
	run_workload c clean $1
	#run_workload c $1
	#run_workload c $1

	# Run WL R - Read Only, Random Reads
	echo
	echo 'Running Workload R'
	run_workload r $1

	# Run WL F - Read-Modify-Write
	echo
	echo 'Running Workload F'
	run_workload f $1

	# Run WL D - Always read latest records
	echo
	echo 'Running Workload D'
	run_workload d $1
	#run_workload d $1
	#run_workload d $1

	# Run WL D - Read in short ranges of records rather than single
	echo
	echo 'Running Workload E'
	run_workload e $1 clean $2

	# Change back all .hd files to .hdr
	#cwd=`pwd`
	#cd logs/hdr
	#for f in *.hd; do
	#    mv $f ${f%.*}".hdr"
	#done
	#cd $cwd
}

run_test $1 

# Reboot host
ssh -t root@$HOST "reboot now"
sleep 300 # 5 minutes

ping $HOST -c 4
if ! [ $? -eq 0 ]; then
    sleep 300 # 5 more mins
    ping $HOST -c 4
	if ! [ $? -eq 0 ]; then
	    echo "Host $HOST not up after 10 minutes!"
	    exit
	fi
fi

echo Host $HOST rebooted successfully...

# Enable THP
ssh root@$HOST "$DIR/enable_thp.sh >> $DIR/monitoring/enable_thp_log 2>&1"
if ! [ $? -eq 0 ]; then
    echo Failed to enable THP on host $HOST
    exit
fi

echo THP Enabled...Starting second benchmark

run_test thp $1
