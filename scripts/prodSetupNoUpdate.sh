#!/bin/sh
echo "enabling production services..."
systemctl start unicef-monitoring-daemon
systemctl start unicef-downloader
systemctl stop edison_config
systemctl stop pulseaudio
systemctl stop redis
echo "done"
echo "you can revert it with devSetup.sh"