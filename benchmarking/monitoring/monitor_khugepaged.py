from subprocess import check_output
import logging
import psutil
import time

filename = 'memusage_mdb_thp.csv'
logging.basicConfig(filename=filename,level=logging.INFO, filemode='w', format='%(asctime)s,%(message)s', datefmt='%a %b %d %H:%M:%S %Y')

def log(message):
    logging.info(message)

def get_huge_page_per(pid):
    df = []
    with open('/proc/{}/smaps'.format(pid)) as f:
        df = list(filter(lambda x: 'AnonHugePages' in x, f.readlines()))
        f.close()
    df = list(map(lambda x: x.split()[1], df))
    total = sum(list(map(lambda x: int(x), df))) # Is in KB
    return (total / sys_mem_kb) * 100


thp_proc_name='khugepaged'
kswapd_names = list(map(lambda x: 'kswapd{}'.format(x), range(8)))
kcompactd_names = list(map(lambda x: 'kcompactd{}'.format(x), range(8)))

mdb_proc_name='/usr/bin/mongod'
thp_pids = [int(check_output(['pidof', thp_proc_name]))]
mdb_pid = int(check_output(['pidof', mdb_proc_name]))

for i in range(8):
    thp_pids.append(int(check_output(['pidof', kswapd_names[i]])))
    thp_pids.append(int(check_output(['pidof', kcompactd_names[i]])))

# log('PID of khugepaged process is {}'.format(pid))
# log('')
# log('Starting to monitor {}'.format(pid))
log('Memory Used (%) Overall,CPU (%) Overall, Memory Used (%) MongoDB, CPU (%) MongoDB, Memory Used (%) khugepaged, CPU (%) khugepaged,Process HugePages (%)')

thp_procs = list(map(lambda x: psutil.Process(x), thp_pids))
mdb_proc = psutil.Process(mdb_pid)

num_cpus = psutil.cpu_count()
# num_cpus = 12

psutil.cpu_percent()
mdb_proc.cpu_percent()
for thp_proc in thp_procs:
    thp_proc.cpu_percent()
sys_mem_kb = (psutil.virtual_memory().total) / 1024

while True:
    time.sleep(1)
    thp_cpu = 0
    thp_mem = 0
    for thp_proc in thp_procs:
        thp_cpu += thp_proc.cpu_percent()
        thp_mem += thp_proc.memory_percent()

    log('{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f}'.format(
            100 * (psutil.virtual_memory().used/psutil.virtual_memory().total), (psutil.cpu_percent()),
            mdb_proc.memory_percent(), mdb_proc.cpu_percent()/num_cpus, # Normalize to 100%
            thp_mem, thp_cpu/num_cpus, # Normalize to 100%
            get_huge_page_per(mdb_pid)
        )
    ) 

 
