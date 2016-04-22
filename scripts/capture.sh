#!/bin/sh
source ./config.txt

FILE_PREFIX=$1

OUTPUT=${data_dir}"/"$FILE_PREFIX".mpeg"

$ffmpeg_binary_path -s 1024x768 -f video4linux2  -i /dev/video0 -f mpeg1video -b 800k -r 30 -t 50 $OUTPUT