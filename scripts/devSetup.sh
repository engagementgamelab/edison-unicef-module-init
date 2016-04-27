#!/bin/sh
systemctl stop unicef-monitoring-daemon
systemctl disable unicef-monitoring-daemon

systemctl stop unicef-downloader
systemctl disable unicef-downloader

systemctl enable edison_config
systemctl start edison_config

systemctl enable wpa_supplicant
systemctl start wpa_supplicant

ifconfig wlan0 up