#!/bin/sh
echo "updating downloader app..."
cd /apps/downloader
git pull
npm install
echo "updating monitoring app..."
cd /apps/monitoring
git pull
npm install

echo "enabling production services..."
systemctl enable unicef-monitoring-daemon
systemctl enable unicef-downloader
systemctl disable edison_config
systemctl disable wpa_supplicant
reboot now