#!/bin/sh
#TODO: Consider using DNS/parameters to use the right hosts (instead of relying on gateway)
set -e

# Configuration
GATEWAY_ADDR=$(ip route list | awk ' /^default/ {print $3}')

# Wait for the DNS server to be up and accepting requests
while ! nslookup . "${GATEWAY_ADDR}" | grep "Server" >/dev/null 2>&1;
do
  sleep 2;
done

# If no argument received run
# Otherwise run the arguments received
# Useful for debug using /bin/bash
if [ -z "$1" ]; then
  if [ ! -f /tls/ca.crt ] || [ ! -f /tls/ca.key ]
  then
    echo "This container must be run with a volume called tls containing the CA files." >&2
    exit 1;
  fi
  rm -f soapui-cert*
  /tls/generate-signed-cert.sh soapui-cert soapui.docker.ahf changeit
  cp -f soapui-min-settings.xml /root/soapui-settings.xml
  for f in ./projects/*.xml ; do
     /ahf/SoapUI-5.2.1/bin/testrunner.sh -h "${GATEWAY_ADDR}" -r "${f}" 2>/dev/null | grep -E "(----|Time|Total)"
  done
else
  exec "$@"
fi

