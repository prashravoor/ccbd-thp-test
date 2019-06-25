# Benchmarking Transparent Huge Pages

## Setup
Install Linux common tools to enable `perf` <br>
`sudo apt install linux-tools-common` <br>
`sudo apt install linux-tools-4.15.0-42-generic` <br>
**This is for Ubuntu 18.04. May need some different version for different OS** <br>
<br>
In addition, ensure GCC version 7.3+ is installed <br>

## Setting up Huge Pages
Before running the code, reserve around 100 2MB huge pages for use by the applications. <br>
```bash
sudo -i
echo 100 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
```
The number of reserved huge pages can be verified using `/proc/meminfo` <br>
```bash
>cat /proc/meminfo | grep Huge
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
HugePages_Total:     100
HugePages_Free:      100
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
```

### Enable Transparent Huge Pages
To enable huge pages, make sure the policy for THP is set to `madvise` <br>
```bash
# cat /sys/kernel/mm/transparent_hugepage/enabled 
always [madvise] never
```

If not, set it to `madvise` using `echo madvise > /sys/kernel/mm/transparent_hugepage/enabled` <br>

## Compilation
`./compile.sh`

## Running the code
It needs to run as superuser since the statistics collected using `perf` need root permissions. <br>
`./run.sh [Matrix Dimension]` <br>
The matrix dimension specifies `n` for an `n x n` matrix. 
For example,`./run.sh 512` <br>
