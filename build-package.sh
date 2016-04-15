#!/bin/sh
source ./config.properties

log(){
	echo `date`": "$1
}


date_string=`date +"%Y_%m_%d-%H_%M_%S"`
random_string=`date | md5sum | head -c 20`
reboot_count=`cat /home/root/REBOOT_COUNT`

rm -fr $temp_data_dir/*
mv $data_dir/* $temp_data_dir

PACKAGE_NAME="${reboot_count}_${date_string}_${random_string}.zip"

log "Building package "${PACKAGE_NAME}

tar -zcvf $PACKAGE_NAME $temp_data_dir/*
