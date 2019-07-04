# Benchmarking MongoDB using YCSB

## Setup
Requirements <br>
* MongoDB (version 4.0.10+)
* Python 3.6+
* Pip3
* The YCSB [benchmark suite](https://github.com/brianfrankcooper/YCSB/releases). Tested with [mongodb binding](https://github.com/brianfrankcooper/YCSB/releases/download/0.15.0/ycsb-mongodb-binding-0.15.0.tar.gz) package of version 0.15.

<br>
Tested on Ubuntu 18.04 <br>
Run `pip install -r requirements.txt` under the `monitoring` folder to install all requirements for monitoring khugepaged.

## Config
Fix the `test_workload.sh` if need to set the path to `YCSB_BASE` <br>

## Capturing Base statistics
Ensure that transparent huge paging is set to `never` or `madvise`, and run `benchmark.sh` to capture logs for base statistics <br>
**Make sure to save all logs under the `logs` folder before proceeding!** <br>

## Capture THP Stats
Enable THP by setting policy to `always`. Then run `benchmark.sh monitor` to capture the statistics of the khugepaged daemon. These logs are stored under the `monitoring` folder. <br>

## Viewing Graphs
**TODO**

