#!/bin/sh
SALT=$(cat /factory/serial_number)
PLAINTEXT="$1"
HASH=$(perl -e "print crypt(${PLAINTEXT},${SALT})")
echo "IoT ssh password = \"${PLAINTEXT}\""
usermod -p ${HASH} root