#!/bin/sh
source ./config.txt
count=`cat ${reboot_cout_file}`
count=$((count+1))
echo ${count} > ${reboot_cout_file}
echo "Incremented REBOOT_COUNT="${count}