#!/bin/bash

DOMAIN=""
DOMAINNAME=`hostname -d`

# Default LDAP Server
DEFAULT_NTP_SERVER=ntp.$DOMAINNAME

echo "Install NTP Client ..."

read -e -p "NTP Server to sync with " -i "$DEFAULT_NTP_SERVER" NTP_SERVER

DATE=`date +%Y-%m-%dT%H:%M:%S`

echo "Backup current ntp configuration ..."
cp /etc/ntp.conf /etc/ntp.conf.$DATE
echo "driftfile /var/lib/ntp/drift

restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery

restrict 127.0.0.1
restrict -6 ::1


# The installation only includes syncronization of NTP server0 to local clock
# add own ntp servers here below
server $NTP_SERVER

includefile /etc/ntp/crypto/pw
keys /etc/ntp/keys

" > /etc/ntp.conf

/sbin/chkconfig ntpd on

echo "(Re)starting services"
/sbin/service ntpd restart

/sbin/service ntpd status
