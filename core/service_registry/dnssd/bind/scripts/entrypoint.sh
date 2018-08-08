#!/bin/sh
set -e

cleanup_handler() {
  kill -- -1
}

# TODO: Re-configure on IP change
# TODO for other containers: Review the possibility of just killing the container on IP change.

trap cleanup_handler 1 2 3 15

# Configure the server
if [ -z "${SERVER_DOMAIN}" ]; then
  SERVER_DOMAIN=$(hostname -d)
  if [ -z "$SERVER_DOMAIN" ]; then
    SERVER_DOMAIN=docker.ahf
    echo "SERVER_DOMAIN defaulted to ${SERVER_DOMAIN}."
  fi
fi
#rndc-confgen -a -r /dev/urandom
./dns-configure.sh

if [ "${USE_KEY}" == true ]; then
  # Make the TSIG key available outside in core-utils format
  echo "key.$SERVER_DOMAIN." > /tsig/tsig
  grep secret /etc/bind/named.conf | cut -d'"' -f2 >> /tsig/tsig
  cp /tsig/tsig /tsig/tsig
fi

# If no argument received, run server
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [ -z "$1" ]; then
  named -g &
  pid=$!
  wait "${pid}"
else
  exec "$@"
fi
