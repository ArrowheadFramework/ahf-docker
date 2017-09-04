#!/bin/bash

DOMAIN=""
#DOMAINNAME=`hostname -d`
DOMAINNAME=$DOCKER_DOMAIN

# Default LDAP Server
DEFAULT_NTP_SERVER=ntp.$DOMAINNAME

BCAST_IP=`ip addr show |grep -w inet |grep -v 127.0.0.1|awk '{ print $4}'`
BCAST_IP=`echo $BCAST_IP|cut -d" " -f1`
DEFAULT_BCAST_IP=${BCAST_IP/255/0}
DEFAULT_NETMASK=`ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f4`
DEFAULT_NETMASK=`echo $DEFAULT_NETMASK|cut -d" " -f1`

DEFAULT_SEARCH_BASE=`echo "ou=mexs_users,$DOMAIN"|tr -d ' '`
DEFAULT_BIND_DN=`echo "cn=admin,$DOMAIN"|tr -d ' '`


echo "Install NTP Server ..."

NETWORK=$DEFAULT_BCAST_IP
NETMASK=$DEFAULT_NETMASK
NTP_SERVER=$DEFAULT_NTP_SERVER
#read -e -p "NTP Restrictions network: " -i "$DEFAULT_BCAST_IP" NETWORK
#read -e -p "NTP Restrictions network mask: " -i "$DEFAULT_NETMASK" NETMASK
#read -e -p "NTP Server to sync with: " -i "$DEFAULT_NTP_SERVER" NTP_SERVER

#DATE=`date +%Y-%m-%dT%H:%M:%S`

#echo "Backup current ntp configuration ..."
#cp /etc/ntp.conf /etc/ntp.conf.$DATE
echo "driftfile /var/lib/ntp/drift

restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict -6 ::1

restrict $NETWORK mask $NETMASK nomodify notrap

# The installation only includes syncronization of NTP server0 to local clock
# add own ntp servers here below
server 127.127.1.0 # local clock 
server 192.36.143.130
server 195.50.171.101
server 212.47.249.141
server 192.33.214.47

includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys

" > /etc/ntp.conf

echo "logfile /var/log/ntpd.log" >> /etc/ntp.conf

#/sbin/chkconfig ntpd on

#echo "(Re)starting services"
/sbin/service ntpd start
/sbin/service ntpd status
