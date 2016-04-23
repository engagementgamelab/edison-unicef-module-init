#!/bin/sh
source ./config.txt

WORKING_DIR=`pwd`

RED='\033[0;31m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo(){
	printf "${YELLOW}$1${NC}\n"
}

error(){
	printf "${RED}$1${NC}\n"
}

important(){
	printf "${BLUE}$1${NC}\n"
}

info(){
	printf "${GREEN}$1${NC}\n"
}

echo "Initializing module "${module_id}

# init ssh access (ssh -i ~/.ssh/unicef_rsa root@192.168.2.15)
mkdir -p /home/root/.ssh
cp -rf ./ssh_keys/* /home/root/.ssh
cat ./ssh_keys/*.pub >> /home/root/.ssh/authorized_keys
chmod 600 /home/root/.ssh/*
./scripts/set_r00t_pass.sh $module_ssh_password

# add WIFI config (wpa_supplicant)
# temp init config and AP mode config (unique SSID)
#echo "Stopping wlan0 ..."
#ifconfig wlan0 down
#echo "Stopping wpa_supplicant ..."
#systemctl stop wpa_supplicant
# sed "s/__WIFI_SSID__/${wifi_ssid}/g;s/__WIFI_PASS__/${wifi_pass}/g" wpa_supplicant.conf.template > wpa_supplicant.conf
sed "s/__AP_SSID__/${ap_ssid}/g;s/__AP_PASS__/${ap_pass}/g" hostapd.conf.template > hostapd.conf
# cp -rf ./wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
cp -rf ./hostapd.conf /etc/hostapd/hostapd.conf

important "Connect Module to your WIFI network with Internet..."
sleep 5
configure_edison --wifi

ping -c 1 google.com &>/dev/null

if [ $? -eq 0 ]
then
  echo "WIFI configuration OK"
else
  error "********************************************"
  error "*** ERROR 001. WIFI configuration failed ***"
  error "********************************************"
  exit -1
fi

echo "Unblocking wlan ..."
rfkill unblock wlan
echo "Starting wpa_supplicant ..."
systemctl start wpa_supplicant

# go online
ifconfig wlan0 up
echo "Waiting for WIFI...15s"
sleep 5
echo "Waiting for WIFI...10s"
sleep 5
echo "Waiting for WIFI...5s"
sleep 5
ifconfig wlan0

# install git
cp -rf ./base-feeds.conf /etc/opkg/
opkg update
opkg install vim
opkg install tar

# ffmpeg
echo "Installing ffmpeg..."
mkdir -p /home/root/ffmpeg
cp -rf ./ffmpeg/* /home/root/ffmpeg

# copy the apps
echo "Downloading the apps..."
rm -fr /apps
mkdir -p /apps/terminal

git clone --branch $app_downloader_version $app_downloader_repo /apps/downloader
cd /apps/downloader
npm install
git clone --branch $app_monitoring_version $app_monitoring_repo /apps/monitoring
cd /apps/monitoring
npm install

cd $WORKING_DIR
cp -fr ./apps/terminal /apps/terminal

cd $WORKING_DIR

echo "Initializing data dirs..."
mkdir -p $data_packages_dir
mkdir -p $data_dir

echo "Initializing data packages..."
touch $package_size_file
touch $package_name_file

# scripts
echo "Installing scripts..."
mkdir -p /home/root/scripts
cp ./scripts/* /home/root/scripts
cp ./config.txt /home/root/scripts

# profile config
echo "Copying profile configs..."
cp -rf .profile /home/root
cp -rf .vimrc /home/root

# disable edison edison_config
systemctl disable edison_config
systemctl disable wpa_supplicant

#symlink to services
rm -fr ~/services
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

# add terminal daemon service
echo "Binding unicef-www-terminal-daemon service..."
cp -rf ./unicef-www-terminal-daemon.service /lib/systemd/system/
systemctl enable unicef-www-terminal-daemon

# init reboot count
echo "Initializing ${reboot_count_file} = 0"
builtin echo "0" > $reboot_count_file

# update hostname
echo "Updating hostname so Edison will be available as 'unicef.local'"
builtin echo "unicef" > /etc/hostname

info "*** Initialization completed successfully ***"
echo ""
echo "Service controll:"
echo "    systemctl start unicef-downloader"
echo "    systemctl start unicef-monitoring-daemon"
echo "    systemctl start unicef-www-terminal-daemon"

echo ""
echo "Service logs:"
echo "    journalctl -f -u unicef-init"
echo "    journalctl -f -u unicef-downloader"
echo "    journalctl -f -u unicef-monitoring-daemon"
echo "    journalctl -f -u unicef-www-terminal-daemon"
echo " "
echo " "
echo " "
echo " "
important "**********************************"
important "Edison will reboot in 5 seconds..."
important "SSH password is ${module_ssh_password}"
important "**********************************"
sleep 5
reboot now