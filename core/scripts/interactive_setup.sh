#!/bin/sh

# script for generating a dns-sd zone file from templates.
#
# author Thorsten Olofsson


ADDRESS=`ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{print $1}'`

echo "NETWORKING=yes
HOSTNAME=host.docker.ahf" > /etc/sysconfig/network
#/etc/init.d/network restart
echo "127.0.1.1	host.docker.ahf
$ADDRESS	host.docker.ahf ns.docker.ahf
127.0.0.1	host.docker.ahf" >> /etc/hosts
echo "/etc/hosts"
cat /etc/hosts
service named start
#hostname host.docker.ahf
#HOSTNAME=`hostname`

#echo $ADDRESS
#read -e -p "Enter local address:" -i "${IPADDR}" ADDRESS

#DOMAIN="${HOSTNAME#*.}"
DOMAIN=$DOCKER_DOMAIN
echo "The domain is '$DOMAIN', please use this when running the container as follows:
docker run -it --privileged -h $DOCKER_HOSTNAME --dns=127.0.0.1 coretest"
#DEFAULTDOMAIN=`hostname -d`
#Run container with the following command to set the hostname
# docker run -h foo.bar.baz -it coretest bash
#read -e -p "Enter domain: " -i "${DEFAULTDOMAIN}" DOMAIN

NETMASK=`ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f4`
#echo $NETMASK
IFS='.' read -a ARRAY <<< "$ADDRESS"

if [ "$NETMASK" = "255.0.0.0" ]; then	
	REV=${ARRAY[0]}
	SUBADDRESS=${ARRAY[1]}.${ARRAY[2]}.${ARRAY[3]}
fi
if [ "$NETMASK" = "255.255.0.0" ]; then
	REV=${ARRAY[1]}.${ARRAY[0]}
	SUBADDRESS=${ARRAY[2]}.${ARRAY[3]}

fi
if [ "$NETMASK" = "255.255.255.0" ]; then
	REV=${ARRAY[2]}.${ARRAY[1]}.${ARRAY[0]}
	SUBADDRESS=${ARRAY[3]}
fi

#echo $REV
#echo $SUBADDRESS

REVSUFFIX=${REV}.in-addr.arpa
#echo $REVSUFFIX
#read -e -p "Enter reverse lookup: " -i "${REV}.in-addr.arpa" REVSUFFIX


CMDKEYGEN="dnssec-keygen"
#echo $CMDKEYGEN
#command -v $CMDKEYGEN -r keyboard >/dev/null #&& DNSSEC="found" || echo "No keygen command:$CMDKEYGEN"



# Start IRQ generator
find / >> /tmp/tmp &
FIND_PID=$!

#if [ "$DNSSEC" = "found" ]; then
KEYNAME=`$CMDKEYGEN -a HMAC-MD5 -b 128 -n HOST $DOMAIN`
#echo $KEYNAME
GENKEY=`cat ${KEYNAME}.private | grep 'Key:' | cut -d: -f2 | cut -c 2-` 
echo Generated key is $GENKEY
rm -f ${KEYNAME}.private ${KEYNAME}.key
#fi

wait $FIND_PID
\rm /tmp/tmp


#read -e -p "Enter key for key.$DOMAIN: " -i "$GENKEY" KEY
GENDIR="/"
#read -e -p "Enter output dir (*WARNING* existing files will be overwritten):" -i "/" GENDIR
#echo $GENDIR

./genzone.sh $ADDRESS $DOMAIN $REVSUFFIX $SUBADDRESS $GENKEY $GENDIR
echo "nameserver $ADDRESS" > /etc/resolv.conf
echo "Address is $ADDRESS"
/sbin/service named restart

./install-ntp-server.sh
./install-glassfish.sh

