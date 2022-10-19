#!/bin/sh
# Purpose: Monitor Linux disk space and send an email alert to $ADMIN
ALERT=20 # alert level
ADMIN="ngoisaoquay" # dev/sysadmin email ID
hostname=`hostname`
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read -r output;
do
  echo "$output"
  usep=$(echo "$output" | awk '{ print $1}' | cut -d'%' -f1 )
  partition=$(echo "$output" | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" |
    #mail -s "Alert: Almost out of disk space $usep%" "$ADMIN"
    bash /root/telegram.sh/telegram -M "Alert: Almost out of disk space on: $hostname $usep%" "$ADMIN"
    echo "deleting G-block logs..."
    rm -rf /home/ubuntu/app-dev/G-Blockchain/explorer/logs/dev/*
    echo "" > $(docker inspect --format='{{.LogPath}}' g-block-explorer)
    break
  fi
done
