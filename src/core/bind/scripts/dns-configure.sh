#!/bin/sh
set -e

# script for generating a dns-sd zone file from templates.
#
# author Thorsten Olofsson
#
# adapted by Fernando Ramirez for ahf-docker

if [ -z "${SERVER_HOSTNAME}" ]; then
  SERVER_HOSTNAME=$(hostname -f)
fi
if [ -z "${SERVER_SHORT_HOSTNAME}" ]; then
  SERVER_SHORT_HOSTNAME=$(hostname -s)
fi
if [ -z "${SERVER_DOMAIN}" ]; then
  SERVER_DOMAIN=$(hostname -d)
  if [ -z "$SERVER_DOMAIN" ]; then
    SERVER_DOMAIN=docker.ahf
    echo "SERVER_DOMAIN defaulted to ${SERVER_DOMAIN}."
  fi
fi
if [ -z "${SERVER_ADDRESS}" ]; then
  if [ -n "${LISTENING_INTERFACE_NAME}" ]; then
    SERVER_ADDRESS=$(ip -4 addr show "${LISTENING_INTERFACE_NAME}" | grep "inet" | tail -n 1 | awk '{print $2}' | \
                                                                     cut -d"/" -f1)
  else
    SERVER_ADDRESS=$(ip route get 1 | awk '{print $NF;exit}')
    echo "SERVER_ADDRESS defaulted to ${SERVER_ADDRESS}."
  fi
fi

HOSTNAME=${SERVER_HOSTNAME} # Yes, we are overriding the variable held by the O.S. as Docker does not update it itself.

netmask=$(ip route | grep "${LISTENING_INTERFACE_NAME}" | grep "[0-9]/[0-9]" | sed -E 's@^.*(/[0-9][0-9]?).*$@\1@g')
oct0=$(echo "${SERVER_ADDRESS}" | cut -d. -f1)
oct1=$(echo "${SERVER_ADDRESS}" | cut -d. -f2)
oct2=$(echo "${SERVER_ADDRESS}" | cut -d. -f3)
oct3=$(echo "${SERVER_ADDRESS}" | cut -d. -f4)
if [ "$netmask" = "/8" ]; then
	rev=${oct0}
	subaddress=${oct1}.${oct2}.${oct3}
elif [ "$netmask" = "/16" ]; then
	rev=${oct1}.${oct0}
	subaddress=${oct2}.${oct3}
elif [ "$netmask" = "/24" ]; then
	rev=${oct2}.${oct1}.${oct0}
	subaddress=${oct3}
else
	>&2 echo "Unexpected netmask: ${netmask}. Please contact maintainer of this container"
	exit 1
fi

revsuffix=${rev}.in-addr.arpa

keygen_cmd="dnssec-keygen"

# Use tsig file if available, otherwise generate key
if [ -f "/tsig/tsig" ]; then
  genkey=$(sed -n 2p < /tsig/tsig)
else
  # Potentially slow on virtual machines
  keyname=$(${keygen_cmd} -a HMAC-MD5 -b 128 -n HOST ${SERVER_DOMAIN})
  genkey=$(grep 'Key:' "${keyname}.private" | cut -d: -f2 | cut -c 2-)
  rm -f "${keyname}.private" "${keyname}.key"
fi

if [ "${ALLOW_DOMAIN_UPDATE}" = true ]
then
  domain_update_allow=any
else
  domain_update_allow=none
fi

gendir="/"

# TODO: Consider inlining genzone here. Is there any benefit in having it apart?
./genzone.sh "$SERVER_ADDRESS" \
             "$SERVER_DOMAIN" \
             "$revsuffix" \
             "$subaddress" \
             "$genkey" \
             "$gendir" \
             "$SERVER_SHORT_HOSTNAME" \
             "$domain_update_allow"

