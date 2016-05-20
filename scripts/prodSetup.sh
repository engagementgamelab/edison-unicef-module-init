#!/bin/sh
cd /apps/downloader
git pull
npm install
cd /apps/monitoring
git pull
npm install

systemctl enable unicef-monitoring-daemon
systemctl enable unicef-downloader
systemctl disable edison_config
systemctl disable wpa_supplicant
reboot now