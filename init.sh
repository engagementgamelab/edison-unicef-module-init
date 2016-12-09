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

sed "s/__AP_SSID__/${ap_ssid}/g;s/__AP_PASS__/${ap_pass}/g" hostapd.conf.template > hostapd.conf
cp -rf ./hostapd.conf /etc/hostapd/hostapd.conf

important "Connect Module to your WIFI network with Internet..."
sleep 5
if [ -f wpa_supplicant.conf ]; then	
    important "WIFI configuration file found"
    cp -rf ./wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
    echo "Stopping wlan0 ..."
	ifconfig wlan0 down
	echo "Stopping wpa_supplicant ..."
	systemctl stop wpa_supplicant
	systemctl start wpa_supplicant
	echo "Starting WIFI..."
	ifconfig wlan0 up
else
	configure_edison --wifi 
	important "Copying WIFI configuration file on SDCARD..."
    cp -rf /etc/wpa_supplicant/wpa_supplicant.conf .
fi

echo "Enabling SSH access..."
cp -fr ./sshd.socket /lib/systemd/system/sshd.socket

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

echo "Installing MRAA, VIM, TAR..."
builtin echo "src mraa-upm http://iotdk.intel.com/repos/3.0/intelgalactic/opkg/i586" > /etc/opkg/mraa-upm.conf
cp -rf ./base-feeds.conf /etc/opkg/
opkg update
opkg install mraa
opkg install vim
opkg install tar

echo "Fixing MRAA..."
cp /usr/lib/libmraa.so /usr/lib/libmraa.so.0

# # ffmpeg
# echo "Installing ffmpeg..."
# mkdir -p /home/root/ffmpeg
# cp -rf ./ffmpeg/* /home/root/ffmpeg

# copy the apps
rm -fr /apps
mkdir -p /apps/terminal
mkdir -p /apps/downloader
mkdir -p /apps/monitoring
mkdir -p /sketch

echo "Installing www terminal app..."
cp -fr ./apps/www-terminal/* /apps/terminal/
cd /apps/terminal/
npm install

echo "Installing downloader app..."
git clone --branch $app_downloader_version $app_downloader_repo /apps/downloader
cd /apps/downloader
npm install

echo "Removing old and then installing new monitoring app..."
# git clone --branch $app_monitoring_version $app_monitoring_repo /apps/monitoring
# cd /apps/monitoring
# npm install

rm -rf /apps/monitoring
mkdir /apps/monitoring
git clone --branch $app_monitoring_version $app_monitoring_repo /apps/monitoring

chmod +x /apps/monitoring/scripts/startup.sh;
chmod +x /apps/monitoring/scripts/shutdown.sh;

mv /apps/monitoring/app/sketch.elf /sketch/sketch.elf;

# Install cronie
opkg install cronie;

cd $WORKING_DIR

echo "Creating cron jobs for start and stopping monitor";
crontab unicefcron;

echo "Initializing SDCARD data dirs..."
mkdir -p $data_packages_dir
mkdir -p $data_packages_dir/logs
mkdir -p $data_root_dir/sensor_data
mkdir -p $data_root_dir/sensor_data/$module_id
mkdir -p $data_dir

echo "Initializing data packages..."
touch $package_size_file
touch $package_name_file
touch $data_root_dir/date.txt

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
systemctl stop edison_config
systemctl disable edison_config
systemctl disable wpa_supplicant
systemctl stop blink-led
systemctl disable blink-led

# disable redis
systemctl disable redis
systemctl disable pulseaudio

# monitoring app error log dir
mkdir -p /home/root/log

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
# echo "Binding unicef-monitoring-daemon service..."
# cp -rf ./unicef-monitoring-daemon.service /lib/systemd/system/
# systemctl enable unicef-monitoring-daemon

# Enable monitor service
echo "Binding new unicef-monitor service..."
cp -rf ./unicef-monitor.service /lib/systemd/system/;
systemctl enable unicef-monitor;

# Disable old monitor
echo "Disabling old unicef-monitoring-daemon service..."
systemctl stop unicef-monitoring-daemon
systemctl disable unicef-monitoring-daemon

# add terminal daemon service
echo "Binding unicef-www-terminal-daemon service..."
cp -rf ./unicef-www-terminal-daemon.service /lib/systemd/system/
systemctl enable unicef-www-terminal-daemon

# init reboot count
echo "Initializing ${reboot_count_file} = 0"
builtin echo "0" > $reboot_count_file

# init rotational speed value
echo "Initializing ${rotational_speed_file} = 20"
echo "20" > /home/root/ROTATION_SPEED

# init rotational duration value
echo "Initializing ${rotation_duration_file} = 20"
echo "20" > /home/root/ROTATION_DURATION


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