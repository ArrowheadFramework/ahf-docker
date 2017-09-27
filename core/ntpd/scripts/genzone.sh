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
SHOST=$7
GLASSFISH_ADDRESS=$8

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
echo "Using outputdir: $GENDIR"
echo "Using short hostname: $SHOST"
echo "Using glassfish address: $GLASSFISH_ADDRESS"
echo

rm -rf ${GENDIR}/var/named/dynamic

mkdir -p $GENDIR
mkdir -p ${GENDIR}/etc
mkdir -p ${GENDIR}/var
mkdir -p ${GENDIR}/var/named
mkdir -p ${GENDIR}/var/named/dynamic

#touch /var/named/dynamic/managed-keys.bind
#touch /var/named/dynamic/managed-keys.bind.jnl
#touch /var/named/dynamic/srv.docker.ahf.jnl

# named.conf
sed -e "s/<host-ip>/${ADDRESS}/g" \
    -e "s/<localdomain>/${DOMAIN}/g" \
    -e "s|<srv-key>|${KEY}|g" \
    -e "s/<rev-localdomain>/${REVSUFFIX}/g" \
    templates/named.conf.template > ${GENDIR}/etc/named.conf

# root zone
sed -e "s/<address>/${ADDRESS}/g" \
    -e "s/<domain>/${DOMAIN}/g" \
    -e "s/<dockershorthost>/${SHOST}/g" \
    -e "s/<glassfish_address>/${GLASSFISH_ADDRESS}/g" \
    templates/root.template > ${GENDIR}/var/named/root

# forward zone
sed -e "s/<address>/${ADDRESS}/g" \
    -e "s/<domain>/${DOMAIN}/g" \
    -e "s/<dockershorthost>/${SHOST}/g" \
    -e "s/<glassfish_address>/${GLASSFISH_ADDRESS}/g" \
    templates/zone.template > ${GENDIR}/var/named/${DOMAIN}

# reverse zone
sed -e "s/<address>/${ADDRESS}/g" \
    -e "s/<domain>/${DOMAIN}/g" \
    -e "s/<dockershorthost>/${SHOST}/g" \
    -e "s/<sub-address>/${SUBADDRESS}/g" \
    templates/rev.template > ${GENDIR}/var/named/${REVSUFFIX}

# service zones
sed -e "s/<domain>/${DOMAIN}/g" \
    templates/srv.template > ${GENDIR}/var/named/dynamic/srv.${DOMAIN}

cp ${GENDIR}/var/named/dynamic/srv.${DOMAIN} ${GENDIR}/var/named/dynamic/srv.${MEXSDOMAIN}.mexs.${DOMAIN}

chown -R root /var/named
chown -R root /var/named/data
chown -R root /var/named/dynamic
chown -R root /var/run/named
chmod 755 -R /var/named
chmod 755 -R /var/named/data
chmod 755 -R /var/run/named

echo Done. Output is in $GENDIR




