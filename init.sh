#!/bin/sh

source ./config.properties

echo "Initializing module "${module_id}

# init ssh access (ssh -i ~/.ssh/unicef_rsa root@192.168.2.15)
mkdir -p /home/root/.ssh
cp -rf ./ssh_keys/* /home/root/.ssh
cat ./ssh_keys/*.pub >> /home/root/.ssh/authorized_keys
chmod 600 /home/root/.ssh/*
./set_r00t_pass.sh

# add WIFI config (wpa_supplicant)
# temp init config and AP mode config (unique SSID)
echo "Stopping wlan0 ..."
ifconfig wlan0 down
echo "Stopping wpa_supplicant ..."
systemctl stop wpa_supplicant
sed "s/__WIFI_SSID__/${wifi_ssid}/g;s/__WIFI_PASS__/${wifi_pass}/g" wpa_supplicant.conf.template > wpa_supplicant.conf
sed "s/__AP_SSID__/${ap_ssid}/g;s/__AP_PASS__/${ap_pass}/g" hostapd.conf.template > hostapd.conf
cp -rf ./wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
cp -rf ./hostapd.conf /etc/hostapd/hostapd.conf

echo "Unblocking wlan ..."
rfkill unblock wlan
echo "Starting wpa_supplicant ..."
systemctl start wpa_supplicant

# go online
ifconfig wlan0 up
echo "Waiting for WIFI..."
sleep 5
ifconfig wlan0

# install git
cp -rf ./base-feeds.conf /etc/opkg/
opkg update
opkg install git
opkg install vim

# ffmpeg
echo "Installing ffmpeg..."
mkdir -p /home/root/ffmpeg
cp -rf ./ffmpeg/* /home/root/ffmpeg

# copy the apps
echo "Copying the apps..."
cp -rf apps/* /apps

# node packages
echo "Installing node packages..."
npm install -g forever
npm install -g express

# profile config
echo "Copying profile configs..."
cp -rf .profile /home/root
cp -rf .vimrc /home/root

# disable edison edison_config.service
systemctl disable edison_config.service

#symlink to services
ln -s /lib/systemd/system ~/services

# add unicef-init service
echo "Binding unicef-init service..."
cp -rf ./unicef-init.service /lib/systemd/system/
systemctl enable unicef-init

# add downloader service
echo "Binding unicef-downloader service..."
cp -rf ./unicef-downloader.service /lib/systemd/system/
systemctl enable unicef-downloader

# add monitoring daemon service
echo "Binding unicef-monitoring-daemon service..."
cp -rf ./unicef-monitoring-daemon.service /lib/systemd/system/
systemctl enable unicef-monitoring-daemon

# init reboot count
echo "Initializing REBOOT_COUNT=0"
echo "0" > /home/root/REBOOT_COUNT
cp -rf ./updateRebootCount.sh /home/root/

# init chrone daily reboot task ???

echo "*******************************"
echo "Initialization completed"
echo "*******************************"
echo ""
echo "Service controll:"
echo "    systemctl start unicef-monitoring-daemon"
echo "    systemctl start unicef-downloader"

echo ""
echo "Service logs:"
echo "    journalctl -f -u unicef-downloader"
echo "    journalctl -f -u unicef-init"
echo "    journalctl -f -u unicef-monitoring-daemon"