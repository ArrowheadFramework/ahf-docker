#!/bin/sh

# script for generating a dns-sd zone file from templates.
#
# author Thorsten Olofsson

ALLARGS=$@
ADDRESS=$1
DOMAIN=$2
REVSUFFIX=$3
SUBADDRESS=$4
KEY=$5
GENDIR=$6

if [ -z "$GENDIR" ]
then
   GENDIR=/
fi


echo
echo "Using address: $ADDRESS"
echo "Using domain: $DOMAIN"
echo "Using reverse zone: $REVSUFFIX"
echo "Using subaddress: $SUBADDRESS"
echo "Using srv key: $KEY"
echo "Using outputdir $GENDIR"
echo

mkdir -p $GENDIR
mkdir -p ${GENDIR}/etc
mkdir -p ${GENDIR}/var
mkdir -p ${GENDIR}/var/named
mkdir -p ${GENDIR}/var/named/dynamic

# named.conf
sed -e "s/<host-ip>/${ADDRESS}/g" \
    -e "s/<localdomain>/${DOMAIN}/g" \
    -e "s|<srv-key>|${KEY}|g" \
    -e "s/<rev-localdomain>/${REVSUFFIX}/g" \
    templates/named.conf.template > ${GENDIR}/etc/named.conf

# root zone
sed -e "s/<address>/${ADDRESS}/g" \
    -e "s/<domain>/${DOMAIN}/g" \
    templates/root.template > ${GENDIR}/var/named/root

# forward zone
sed -e "s/<address>/${ADDRESS}/g" \
    -e "s/<domain>/${DOMAIN}/g" \
    -e "s/<dockershorthost>/${DOCKER_SHORT_HOSTNAME}/g" \
    templates/zone.template > ${GENDIR}/var/named/${DOMAIN}

# reverse zone
sed -e "s/<address>/${ADDRESS}/g" \
    -e "s/<domain>/${DOMAIN}/g" \
    -e "s/<dockershorthost>/${DOCKER_SHORT_HOSTNAME}/g" \
    -e "s/<sub-address>/${SUBADDRESS}/g" \
    templates/rev.template > ${GENDIR}/var/named/${REVSUFFIX}

# service zones
sed -e "s/<domain>/${DOMAIN}/g" \
    templates/srv.template > ${GENDIR}/var/named/dynamic/srv.${DOMAIN}

MEXSDOMAIN=mexdomain
cp ${GENDIR}/var/named/dynamic/srv.${DOMAIN} ${GENDIR}/var/named/dynamic/srv.${MEXSDOMAIN}.mexs.${DOMAIN}

chown named /var/named
chown named /var/named/data
chmod 755 /var/named
#chmod 755 /var/run/named/named.pid
#chmod 755 /var/run/named/session.key

echo Done. Output is in $GENDIR




