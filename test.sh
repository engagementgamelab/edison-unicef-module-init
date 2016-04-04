#!/bin/sh
source ./config.properties
sed "s/__WIFI_SSID__/${wifi_ssid}/g;s/__WIFI_PASS__/${wifi_pass}/g;s/__AP_SSID__/${ap_ssid}/g;s/__AP_PASS__/${ap_pass}/g;" wpa_supplicant.conf.template > wpa_supplicant.conf