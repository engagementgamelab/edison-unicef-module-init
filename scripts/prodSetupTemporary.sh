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
systemctl start unicef-monitoring-daemon
systemctl start unicef-downloader
systemctl stop edison_config
systemctl stop wpa_supplicant
ifconfig wlan0 down
echo "done"
echo "you can revert it with devSetup.sh"