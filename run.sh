#! /bin/bash

PERF='sudo perf stat -e page-faults,dTLB-load-misses,dTLB-loads,dTLB-store-misses,dTLB-stores'
SIZE=512

if [ $# == 1 ]; then
    SIZE=$1
fi

echo "Matrix Multiplication trials - size: $SIZE x $SIZE"
echo

echo "Regular memory allocation"
$PERF ./malloc_matmul $SIZE
echo

echo "Allocation using mmap"
$PERF ./mmap_matmul $SIZE
echo

echo "Allocation through THP using madvise"
$PERF ./madvise_thp $SIZE
echo

