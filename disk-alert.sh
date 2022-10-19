#!/bin/sh
# Purpose: Monitor Linux disk space and send an email alert to $ADMIN
ALERT=20 # alert level
ADMIN="thind" # dev/sysadmin email ID
hostname=`hostname`
disk_usage () {
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read -r output;
do
  echo "$output"
  usep=$(echo "$output" | awk '{ print $1}' | cut -d'%' -f1 )
  #echo "day la so nguyen: $usep"
  partition=$(echo "$output" | awk '{ print $2 }' )
  #echo "$partition"
  if [ $usep -ge $ALERT ]; then
    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" |
    #mail -s "Alert: Almost out of disk space $usep%" "$ADMIN"
    bash /root/telegram-alert/telegram -M "Alert: Almost out of disk space on: $hostname $usep%" "$ADMIN"
    #echo "deleting something logs..."
    #rm -rf /home/ubuntu/app-dev/G-Blockchain/explorer/logs/dev/*
    #echo "" > $(docker inspect --format='{{.LogPath}}' g-block-explorer)
    break
  fi
done
}
#MEMORY usage
memory_usage () {
#mem_free=`free -m | grep "Mem" | awk '{print $4+$6}'`
mem_free=`free | awk '/Mem/{printf("RAM Usage: %.2f%\n"), $3/$2*100}' |  awk '{print $3}' | cut -d"." -f1`
 echo "memory running usage : $mem_free "
if [ $mem_free -ge $ALERT  ]
    then
        echo "mem warning!!!"
    else
        echo "mem ok!!!"
fi
}
#CPU usage
cpu_usage () {
cpu=`top -bn1 | grep load | awk '{printf "%.2f%\n", $(NF-2)}'`
cpuuse=$(cat /proc/loadavg | awk '{print $1}')
if  [ "$cpuuse" > $ALERT ];
 then
         echo "CPU warning"
 else
         echo "CPU ok!!!"
fi
}
disk_usage
memory_usage
cpu_usage
