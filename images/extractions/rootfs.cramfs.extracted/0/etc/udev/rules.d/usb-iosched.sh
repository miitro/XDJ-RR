#!/bin/sh
# setting USB drive io-scheduler

#dev=$1
#/bin/echo noop > /sys/block/${dev/[1-9]/}/queue/scheduler
/bin/echo noop > /sys/block/$1/queue/scheduler
/bin/echo 8 > /sys/block/$1/queue/max_sectors_kb
#/bin/echo 1 > /sys/block/$1/queue/nomerges

