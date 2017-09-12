#!/bin/sh

# script for generating a dns-sd zone file from templates.
#
# author Thorsten Olofsson
#
# adapted by Fernando Ramirez for ahf-docker

#TODO Change these ifconfigs for ip calls
ADDRESS=`ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{print $1}'`
HOSTNAME=`hostname`
SHORT_HOSTNAME=`hostname -s`
GLASSFISH_ADDRESS=`dig +short glassfish` #TODO: Change glassfish hostname for variable gotten from docker
DOMAIN=`hostname -d`
if [[ -z "$DOMAIN" ]]; then
  DOMAIN=local
fi
NETMASK=`ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f4`
IFS='.' read -a ARRAY <<< "$ADDRESS"
if [[ "$NETMASK" = "255.0.0.0" ]]; then	
	REV=${ARRAY[0]}
	SUBADDRESS=${ARRAY[1]}.${ARRAY[2]}.${ARRAY[3]}
fi
if [[ "$NETMASK" = "255.255.0.0" ]]; then
	REV=${ARRAY[1]}.${ARRAY[0]}
	SUBADDRESS=${ARRAY[2]}.${ARRAY[3]}
fi
if [[ "$NETMASK" = "255.255.255.0" ]]; then
	REV=${ARRAY[2]}.${ARRAY[1]}.${ARRAY[0]}
	SUBADDRESS=${ARRAY[3]}
fi

REVSUFFIX=${REV}.in-addr.arpa

CMDKEYGEN="dnssec-keygen"

# Start IRQ generator
find / >> /tmp/tmp &
FIND_PID=$!

KEYNAME=`$CMDKEYGEN -a HMAC-MD5 -b 128 -n HOST $DOMAIN`
GENKEY=`cat ${KEYNAME}.private | grep 'Key:' | cut -d: -f2 | cut -c 2-` 
rm -f ${KEYNAME}.private ${KEYNAME}.key

wait $FIND_PID
rm /tmp/tmp

GENDIR="/"

./genzone.sh $ADDRESS $DOMAIN $REVSUFFIX $SUBADDRESS $GENKEY $GENDIR $SHORT_HOSTNAME $GLASSFISH_ADDRESS

