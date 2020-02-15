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
    pages = [int(x)/2048 for x in df]
    total = sum(list(map(lambda x: int(x), df))) # Is in KB
    return (total / sys_mem_kb) * 100, int(sum(pages))


thp_proc_name='khugepaged'
num_numa_nodes=2
kswapd_names = list(map(lambda x: 'kswapd{}'.format(x), range(num_numa_nodes)))
kcompactd_names = list(map(lambda x: 'kcompactd{}'.format(x), range(num_numa_nodes)))

mdb_proc_name='/usr/bin/mongod'
thp_pids = [int(check_output(['pidof', thp_proc_name]))]
mdb_pid = int(check_output(['pidof', mdb_proc_name]))

for i in range(num_numa_nodes):
    thp_pids.append(int(check_output(['pidof', kswapd_names[i]])))
    thp_pids.append(int(check_output(['pidof', kcompactd_names[i]])))

# log('PID of khugepaged process is {}'.format(pid))
# log('')
# log('Starting to monitor {}'.format(pid))
log('Memory Used (%) Overall,CPU (%) Overall, Memory Used (%) MongoDB, CPU (%) MongoDB, Memory Used (%) khugepaged, CPU (%) khugepaged,Process HugePages (%),Network Load (BPS),Number of Huge Pages')

thp_procs = list(map(lambda x: psutil.Process(x), thp_pids))
mdb_proc = psutil.Process(mdb_pid)

num_cpus = psutil.cpu_count()
# num_cpus = 12

net_if = 'eno1' # Change as per system need
warned = False

def get_net_stats():
    global warned
    netstats = psutil.net_io_counters(pernic=True)
    if not net_if in netstats:
        if not warned:
            print('{} not the correct NIC! System wide stats will be collected instead...')
            warned = True
        netstats = psutil.net_io_counters()
    else:
        netstats = netstats[net_if]
    return netstats

def human_readable(load):
    suffix = 'BKMG'
    i = 0
    rem = float(load)
    while rem > 999 and i < 3:
        rem /= 1000.
        i += 1
    
    return '{:.2f}{}'.format(rem, suffix[i])

sleep_time = 3

psutil.cpu_percent()
mdb_proc.cpu_percent()
for thp_proc in thp_procs:
    thp_proc.cpu_percent()
sys_mem_kb = (psutil.virtual_memory().total) / 1024

iter_ctr = 0
while True:
    netstats = get_net_stats()
    time.sleep(sleep_time)
    netstats_new = get_net_stats()
    bytes_sent = netstats_new.bytes_sent - netstats.bytes_sent
    bytes_recv = netstats_new.bytes_recv - netstats.bytes_recv
    net_load = (8 * (bytes_sent + bytes_recv)) / float(sleep_time)
    net_load = human_readable(net_load)

    thp_cpu = 0
    thp_mem = 0
    for thp_proc in thp_procs:
        thp_cpu += thp_proc.cpu_percent()
        thp_mem += thp_proc.memory_percent()

    mdb_mem_percent = mdb_proc.memory_percent()
    if iter_ctr % 3 == 0:
        huge_page_per,num_pages = get_huge_page_per(mdb_pid)
    huge_page_per = (huge_page_per / mdb_mem_percent) * 100 # huge_page_per is percentage of overall memory. Dividing by mdb_mem_percent gives % huge pages of MongoDB memory
    log('{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{:.2f},{},{}'.format(
            100 * (psutil.virtual_memory().used/psutil.virtual_memory().total), (psutil.cpu_percent()),
            mdb_mem_percent, mdb_proc.cpu_percent()/num_cpus, # Normalize to 100%
            #mdb_mem_percent, mdb_proc.cpu_percent(), # Normalize to 100%
            #thp_mem, thp_cpu/num_cpus, # Normalize to 100%
            thp_mem, thp_cpu, # Normalize to 100%
            huge_page_per,net_load,num_pages
        )
    )
    iter_ctr += 1 

