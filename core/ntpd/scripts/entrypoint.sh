#!/bin/bash
set -e

rm -f /tsig/tsig

# Configure the server  
SERVER_HOSTNAME=`hostname -f`
SERVER_DOMAIN=`hostname -d`
service named stop
rndc-confgen -a -r /dev/urandom
chown root /etc/rndc.key
chmod 755 /etc/rndc.key
/ahf/dns-configure.sh
mkdir -p /out
echo "key.$SERVER_DOMAIN." > /out/tsig
grep secret /etc/named.conf | cut -d'"' -f2 >> /out/tsig
chmod 777 /out/tsig
mkdir -p /tsig
cp /out/tsig /tsig/tsig

# If no argument received, run server
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [[ -z "$1" ]]; then
  named -g
else
  exec "$@"
fi
