#!/bin/sh
echo "enabling and starting production services..."
systemctl enable unicef-monitoring-daemon
systemctl start unicef-monitoring-daemon
systemctl enable unicef-downloader
systemctl start unicef-downloader
systemctl stop edison_config
systemctl disable edison_config
systemctl stop pulseaudio
systemctl stop redis
echo "done"
echo "you can revert it with devSetup.sh"