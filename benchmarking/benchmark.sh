#!/bin/bash

# Workload run order got from: https://github.com/brianfrankcooper/YCSB/wiki/Core-Workloads 

DIR=/home/student1/thp/ccbd-thp-test/benchmarking
HOST=

run_workload()
{
    wl=$1
    thp=$2
    if [ ! -z $2 ] && [ $2 == 'clean' ]; then
        clean=$2
        thp=$3
    fi

    ssh -t root@$HOST "nohup $DIR/start_record.sh $wl"
    ./test_workload.sh $wl $clean $thp
    ssh -t root@$HOST "nohup $DIR/stop_record.sh $wl"
    cwd=`pwd`
    cd $DIR/logs/hdr
    for f in *.hdr; do
	if [ -e "$f" ]; then
	# Use .hd instead of .hdr to avoid recursive expansion of files from previous workloads
	    mv $f ${f%.*}"_"$wl".hd"
   	fi
    done
    cd $cwd
}


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
run_workload c $1

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

# Run WL D - Read in short ranges of records rather than single
echo
echo 'Running Workload E'
run_workload e $1 clean $2

# Change back all .hd files to .hdr
cwd=`pwd`
cd logs/hdr
for f in *.hd; do
    mv $f ${f%.*}".hdr"
done
cd $cwd
