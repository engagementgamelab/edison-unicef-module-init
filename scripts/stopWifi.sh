#!/bin/sh
echo "Stopping WIFI mode..."
systemctl stop wpa_supplicant
ifconfig wlan0 down

# Start monitor as fallback in case time never set
systemctl enable unicef-monitor
systemctl start unicef-monitor

sleep 5
ifconfig