#!/bin/sh
echo "Starting AP mode..."
ifconfig wlan0 up
systemctl stop wpa_supplicant
systemctl start hostapd