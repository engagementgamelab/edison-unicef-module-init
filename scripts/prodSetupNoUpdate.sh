#!/bin/sh
echo "enabling production services..."
systemctl start unicef-monitoring-daemon
systemctl start unicef-downloader
systemctl stop edison_config
systemctl stop wpa_supplicant
systemctl stop pulseaudio
systemctl stop redis
ifconfig wlan0 down
echo "done"
echo "you can revert it with devSetup.sh"