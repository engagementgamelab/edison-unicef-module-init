#!/bin/sh
echo "Stopping AP mode..."
systemctl stop hostapd
systemctl stop wpa_supplicant
ifconfig wlan0 down
systemctl disable blink-led