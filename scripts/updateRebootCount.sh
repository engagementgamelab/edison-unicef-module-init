#!/bin/sh
source /home/root/scripts/config.txt
count=`cat ${reboot_count_file}`
count=$((count+1))
echo ${count} > ${reboot_count_file}
echo "Incremented REBOOT_COUNT="${count}
echo "Creating DATA dirs if don't exist"
mkdir -p $data_packages_dir
mkdir -p $data_packages_dir/logs
mkdir -p $data_dir