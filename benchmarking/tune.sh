#!/bin/bash
echo "Setting vm.dirty_ratio"
sysctl -w vm.dirty_ratio=15
echo "Setting vm.dirty_background_ratio"
sysctl -w vm.dirty_background_ratio=5
echo "Setting vm.swappiness"
sysctl -w vm.swappiness=1
echo "Changing IO schedular to deadline"
echo deadline > /sys/block/sda/queue/schedular
echo "Read ahead in linux"
blockdev --setra 32 /dev/sda
echo "Changing Network stack"
sysctl -w net.core.somaxconn=4096
sysctl -w net.ipv4.tcp_fin_timeout=30
sysctl -w net.ipv4.tcp_keepalive_intvl=30
sysctl -w net.ipv4.tcp_keepalive_time=120
sysctl -w net.ipv4.tcp_max_syn_backlog=4096
echo "Linux is tuned for mongodb"
