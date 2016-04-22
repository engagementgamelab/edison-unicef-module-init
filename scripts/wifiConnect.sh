#!/bin/sh
systemctl start wpa_supplicant
ifconfig wlan0 up