#!/bin/sh

source /home/root/scripts/config.txt

date_string=`date +"%Y_%m_%d-%H_%M_%S"`
random_string=`< /dev/urandom tr -dc A-Za-z0-9 | head -c20`
reboot_count=`cat ${reboot_count_file}`
NEW_PACKAGE_PREFIX="${reboot_count}_${date_string}_${random_string}"

touch $data_dir/$NEW_PACKAGE_PREFIX.jpg
touch $data_dir/$NEW_PACKAGE_PREFIX.mpeg
touch $data_dir/$NEW_PACKAGE_PREFIX.txt

./archive.sh $NEW_PACKAGE_PREFIX
