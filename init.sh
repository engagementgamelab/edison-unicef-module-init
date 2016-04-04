#!/bin/sh

source ./config.properties

echo "Initializing module "${module_id}

# init ssh access (ssh -i ~/.ssh/unicef_rsa root@192.168.2.15)
mkdir /home/root/.ssh
cp ./ssh_keys/* /home/root/.ssh
cat ./ssh_keys/*.pub >> /home/root/.ssh/authorized_keys
chmod 600 /home/root/.ssh/*
./set_r00t_pass.sh

# add WIFI config (wpa_supplicant)
# temp init config and AP mode config (unique SSID)
ifconfig wlan0 down
systemctl stop wpa_supplicant
sed "s/__WIFI_SSID__/${wifi_ssid}/g;s/__WIFI_PASS__/${wifi_pass}/g" wpa_supplicant.conf.template > wpa_supplicant.conf
sed "s/__AP_SSID__/${ap_ssid}/g;s/__AP_PASS__/${ap_pass}/g" .hostapd.conf.template > .hostapd.conf
cp ./wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
cp ./hostapd.conf /etc/hostapd/hostapd.conf

rfkill unblock wlan
systemctl start wpa_supplicant

# go online
ifconfig wlan0 up
echo "Waiting for WIFI..."
ifconfig wlan0
sleep 5

# install git
cp ./base-feeds.conf /etc/opkg/
opkg update
opkg install git
opkg install vim

# ffmpeg
mkdir /home/root/ffmpeg
cp -ar ./ffmpeg/* /home/root/ffmpeg

# copy the apps
cp -ar apps/* /apps

# node packages
npm install -g forever

# profile config
cp .profile /home/root
cp .vimrc /home/root

# add unicef-init service
cp ./unicef-init.service /lib/systemd/system/
systemctl enable unicef-init

# add downloader service
cp ./unicef-init.service /lib/systemd/system/
systemctl enable unicef-init

# add monitoring daemon service
cp ./unicef-monitoring-daemon.service /lib/systemd/system/
systemctl enable unicef-monitoring-daemon

# init reboot count
echo "0" > /home/root/REBOOT_COUNT
cp ./updateRebootCount.sh /home/root/

# init chrone daily reboot task ???