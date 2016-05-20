#!/bin/sh
cd /apps/downloader
git pull
npm install
cd /apps/monitoring
git pull
npm install

systemctl start unicef-monitoring-daemon
systemctl start unicef-downloader
systemctl stop edison_config
systemctl stop wpa_supplicant
ifconfig wlan0 down