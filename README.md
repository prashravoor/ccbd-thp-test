# Benchmarking Transparent Huge Pages

## Setup
Install Linux common tools to enable `perf` <br>
`sudo apt install linux-tools-common` <br>
`sudo apt install linux-tools-4.15.0-42-generic` <br>
**This is for Ubuntu 18.04. May need some different version for different OS** <br>
<br>
In addition, ensure GCC version 7.3+ is installed <br>

## Compilation
`./compile.sh`

## Running the code
It needs to run as superuser since the statistics collected using `perf` need root permissions. <br>
`./run.sh [Matrix Dimension]` <br>
The matrix dimension specifies `n` for an `n x n` matrix. 
For example,`./run.sh 512` <br>
