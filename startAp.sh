#!/bin/sh
echo "Starting AP mode..."
systemctl stop wpa_supplicant
ifconfig wlan0 up
systemctl start hostapd