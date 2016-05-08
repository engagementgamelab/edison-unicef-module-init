#!/bin/sh
source /home/root/scripts/config.txt

FILE_PREFIX=$1
DURATION=$2

OUTPUT=${data_dir}"/"$FILE_PREFIX".mpeg"

# fs - max file size 10MB
# y always overwrite
# stats - stats
# s resolution
# f codec
# i input dev
# t - time
# r framerate
# b bitrate
# f output format
$ffmpeg_binary_path  -y -stats -f video4linux2 -i /dev/video0 -s 1024x768 -video_size hd720 -b 800k -t $DURATION -r 30 $OUTPUT

#ffmpeg -y -stats -f video4linux2 -i /dev/video0 -s 1024x768 -video_size hd720 -b 800k -t 20 -r 30