#!/bin/sh
count=`cat /home/root/REBOOT_COUNT`
count=$((count+1))
echo ${count} > /home/root/REBOOT_COUNT
echo "Incremented REBOOT_COUNT="${count}