#!/bin/sh
SALT=$(cat /factory/serial_number)
PLAINTEXT="edison"
HASH=$(perl -e "print crypt(${PLAINTEXT},${SALT})")
echo "IoT ssh password = \"${PLAINTEXT}\""
usermod -p ${HASH} root