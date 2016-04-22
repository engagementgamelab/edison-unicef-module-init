#!/bin/sh
source ./config.txt

log(){
	echo `date`": "$1
}

createPackageName(){
	date_string=`date +"%Y_%m_%d-%H_%M_%S"`
	random_string=`< /dev/urandom tr -dc A-Za-z0-9 | head -c20`
	reboot_count=`cat /home/root/REBOOT_COUNT`
	NEW_PACKAGE_NAME="${reboot_count}_${date_string}_${random_string}.tar.gz"	

	log "Creating new package ${PACKAGE_NAME} ..."
	return $NEW_PACKAGE_NAME
}

# *****
# START
# *****
FILES_PREFIX=$1

mkdir -p $data_packages_dir
mkdir -p $data_dir

# load package datapoint count

# if count > 100 create new package

# else use the latest package

log "Appending files *${FILES_PREFIX}* to package ${PACKAGE_NAME}"

tar -zcvf "${data_packages_dir}/${PACKAGE_NAME}" "${data_dir}/*${FILES_PREFIX}*"
rm -fr "${data_dir}/*${FILES_PREFIX}*"