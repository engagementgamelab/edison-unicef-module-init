#!/bin/sh
SALT=$(cat /factory/serial_number)
PLAINTEXT="edison"
HASH=$(perl -e "print crypt(${PLAINTEXT},${SALT})")
echo "Password Hash = \"${HASH}\""
usermod -p ${HASH} root