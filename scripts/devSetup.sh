#!/bin/sh
systemctl disable unicef-monitoring-daemon
systemctl stop unicef-monitoring-daemon
systemctl enable edison_config
systemctl start edison_config
systemctl enable wpa_supplicant
systemctl start wpa_supplicant
ifconfig wlan0 up