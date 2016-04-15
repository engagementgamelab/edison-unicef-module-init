#!/bin/sh
source ./config.properties

log(){
	echo `date`": "$1
}

mkdir -p $data_packages_dir
mkdir -p $data_dir
mkdir -p $temp_data_dir

date_string=`date +"%Y_%m_%d-%H_%M_%S"`
random_string=`date | md5sum | head -c 20`
reboot_count=`cat /home/root/REBOOT_COUNT`

rm -fr $temp_data_dir/*
mv $data_dir/* $temp_data_dir

PACKAGE_NAME="${reboot_count}_${date_string}_${random_string}.tar.gz"

log "Building package "${PACKAGE_NAME}

tar -zcvf "${data_packages_dir}/${PACKAGE_NAME}" $temp_data_dir/*
