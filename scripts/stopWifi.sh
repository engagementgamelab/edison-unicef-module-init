#!/bin/sh
echo "Stopping WIFI mode..."
systemctl stop wpa_supplicant
ifconfig wlan0 down

sleep 5
ifconfig wlan0