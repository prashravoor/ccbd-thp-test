#! /bin/bash

# Compile

MMAP=mmap_matmul
MADV=madvise_thp
NORM=malloc_matmul
FLAGS='-g -O0'
rm $MMAP $MADV $NORM

gcc $FLAGS -o $MMAP mmap-matmul.c
gcc $FLAGS -o $MADV madvise-thp.c
gcc $FLAGS -o $NORM mat-mul.c
