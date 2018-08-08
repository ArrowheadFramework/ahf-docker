#!/bin/sh

# script for generating a dns-sd zone file from templates.
#
# author Thorsten Olofsson
#
# modified by Fernando Ramirez

#ALLARGS=$@
address=$1
domain=$2
revsuffix=$3
subaddress=$4
key=$5
gendir=$6
short_host=$7
domain_update_allow=$8

if [ -z "${gendir}" ]
then
   gendir=/
fi

echo
echo "Using address: $address"
echo "Using domain: $domain"
echo "Using reverse zone: $revsuffix"
echo "Using subaddress: $subaddress"
echo "Using srv key: $key"
echo "Using outputdir: $gendir"
echo "Using short hostname: $short_host"
echo "Allowing DNS to domain $domain to: $domain_update_allow"
echo

rm -rf ${gendir}/var/named/dynamic

mkdir -p ${gendir}
mkdir -p ${gendir}/etc
mkdir -p ${gendir}/var
mkdir -p ${gendir}/var/named
mkdir -p ${gendir}/var/named/dynamic

if [ "${USE_KEY}" == true ]; then
  sed -ie "s/#KEY-DISABLED//g"\
      templates/named.conf.template
fi

# named.conf
sed -e "s/<host-ip>/${address}/g" \
    -e "s/<localdomain>/${domain}/g" \
    -e "s|<srv-key>|${key}|g" \
    -e "s/<rev-localdomain>/${revsuffix}/g" \
    -e "s/<domain_update_allow>/${domain_update_allow}/g" \
    templates/named.conf.template > "${gendir}/etc/bind/named.conf"

# root zone
sed -e "s/<address>/${address}/g" \
    -e "s/<domain>/${domain}/g" \
    templates/root.template > "${gendir}/var/named/root"

# forward zone
sed -e "s/<address>/${address}/g" \
    -e "s/<domain>/${domain}/g" \
    -e "s/<glassfish_address>/${glassfish_address}/g" \
    templates/zone.template > "${gendir}/var/named/${domain}"

# reverse zone
sed -e "s/<address>/${address}/g" \
    -e "s/<domain>/${domain}/g" \
    -e "s/<sub-address>/${subaddress}/g" \
    templates/rev.template > "${gendir}/var/named/${revsuffix}"

# service zones
sed -e "s/<domain>/${domain}/g" \
    templates/srv.template > "${gendir}/var/named/dynamic/srv.${domain}"

cp "${gendir}/var/named/dynamic/srv.${domain}" "${gendir}/var/named/dynamic/srv.${MEXSDOMAIN}.mexs.${domain}"

chown -R root /var/named
chown -R root /var/named/data
chown -R root /var/named/dynamic
chown -R root /var/run/named
chmod 755 -R /var/named
chmod 755 -R /var/named/data
chmod 755 -R /var/run/named

echo Done. Output is in ${gendir}




