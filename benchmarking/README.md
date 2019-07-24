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
Ensure that transparent huge paging is set to `never` or `madvise`, and run `benchmark.sh` to capture logs for base statistics. Specify the `monitor` argument as well, to capture memory and CPU usage stats <br>
**Make sure to save all logs under the `logs` folder before proceeding!** <br>
Run the `delete_logs.sh` script to create a tarball of all needed logs, and save it to the folder `logs/backups` <br>

## Capture THP Stats
Enable THP by setting policy to `always`. Then run `benchmark.sh monitor thp` to capture the statistics of the khugepaged daemon. These logs are stored under the `monitoring` folder. <br>

## Viewing Graphs
* To view a summary of performance of THP vs regular pages, extract the required logs, copy the files with the prefix `json_*` from both log sets to a common folder, say `logs`, and run `python plots/plot_summaries.py logs` to generate a graph.
* To view memory and CPU usage patterns of a particular workload run, use `python plots/plot_mem_usage.py monitoring/memusage_...`. It generates two graphs, one for CPU usage, and another for Memory usage. 
* To view a histogram of average latencies for a particular workload, run `python plots/plot_histograms.py <JSON file>`, for e.g. `python plots/plot_histograms.py logs/json_a_thp.json`

## Running MySQL benchmarks (Sysbench)
MySQL benchmarks can be run with sysbench and MySQL server installed. Install sysbench first through `sudo apt install sysbench` <br>
Install MySQL server (version 5.7+), and modify the `mysql_test_workload.sh` file and set the correct username and password for the mysql server <br> 
Then run the `mysql-bench.sh` script to start executing the mysql benchmarks <br>
(If running with THP enabled, run with `mysql-bench.sh thp` to mark all logs as run with THP enabled. Ease of use only) <br>
`collect_mysql_logs.sh` will make a tar of the necessary log files and place them in the logs/backups folder <br>
Copy relevent log files to a single folder (thp logs should have a `_thp.log` suffix, and fragmented thp files should have `_thp_frag.log` suffix <br>
Once all files have been copied to a single folder, run `python plots/mysql_plot_graphs.py <folder> [save]` to generate a graph (The "save" option if specified, generates csv files that saves intermediate results <br>

## Running MySQL benchmarks (YCSB)
Similar to setting up the mongodb-binding, setup the jdbc-binding <br>
There is an error in the YCSB JdbcCreateTable code, so that utility cannot be used by default. Obtain the source for YCSB, and modify the following file: <br>
Change the line `(YCSB_KEY VARCHAR PRIMARY KEY` in the `createTable` function in the file `YCSB/jdbc/src/main/java/com/yahoo/ycsb/db/JdbcDBCreateTable.java` to <br>
`(YCSB_KEY VARCHAR(255) PRIMARY KEY` <br>
Then compile the code using the command `mvn -pl com.yahoo.ycsb:jdbc-binding -am clean package` <br>
There would be a tarball generated under `jdbc/target` folder, which can be extracted to a suitable location (Set this path as the `YCSB_BASE` path in the file `mysql_test_workload.sh` file) <br>
Set the correct properties for the database in the file `db.properties` <br>
Run the YCSB benchmark for MySQL by running the script `mysql-bench.sh ycsb [thp]` <br>
Collection of logs, Generation of graphs etc. is identical to procedure with MongoDB <br>
