from subprocess import check_output
import logging
import psutil
import time

filename = 'memusage_sql_thp.csv'
logging.basicConfig(filename=filename,level=logging.INFO, filemode='w', format='%(asctime)s,%(message)s', datefmt='%a %b %d %H:%M:%S %Y')

def log(message):
    logging.info(message)

thp_proc_name='khugepaged'
mdb_proc_name='mysqld'
thp_pid = int(check_output(['pidof', thp_proc_name]))
mdb_pid = int(check_output(['pidof', mdb_proc_name]))

# log('PID of khugepaged process is {}'.format(pid))
# log('')
# log('Starting to monitor {}'.format(pid))
log('Memory Used (%) Overall,CPU (%) Overall, Memory Used (%) MongoDB, CPU (%) MongoDB, Memory Used (%) khugepaged, CPU (%) khugepaged')

thp_proc = psutil.Process(thp_pid)
mdb_proc = psutil.Process(mdb_pid)

num_cpus = psutil.cpu_count()

psutil.cpu_percent()
mdb_proc.cpu_percent()
thp_proc.cpu_percent()
while True:
    time.sleep(1)
    log('{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f}'.format(
            100 * (psutil.virtual_memory().used/psutil.virtual_memory().total), (psutil.cpu_percent()),
            mdb_proc.memory_percent(), mdb_proc.cpu_percent()/num_cpus, # Normalize to 100%
            thp_proc.memory_percent(), thp_proc.cpu_percent()/num_cpus # Normalize to 100%
        )
    ) 

 
