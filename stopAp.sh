#!/bin/sh
echo "Stopping AP mode..."
systemctl stop hostapd
#systemctl start wpa_supplicant
ifconfig wlan0 up