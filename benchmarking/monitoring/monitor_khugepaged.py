from subprocess import check_output
import logging
import psutil
import time

filename = 'khugepaged_log'
logging.basicConfig(filename=filename,level=logging.INFO, filemode='w', format='%(asctime)s,%(message)s', datefmt='%a %b %d %H:%M:%S %Y')

def log(message):
    logging.info(message)

proc_name='khugepaged'
pid = int(check_output(['pidof', proc_name]))
# log('PID of khugepaged process is {}'.format(pid))
# log('')
# log('Starting to monitor {}'.format(pid))
log('Memory (MB),CPU (%)')

while True:
    proc = psutil.Process(pid)
    log('{},{}'.format((proc.memory_info_ex().rss)/(1024.0 * 1024.0), proc.cpu_percent(interval=1))) 

 
