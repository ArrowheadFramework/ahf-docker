#!/bin/bash
set -e

# Configure the server  
SERVER_HOSTNAME=`hostname -f`
service named stop
rndc-confgen -a -r /dev/urandom
chown root /etc/rndc.key
chmod 755 /etc/rndc.key
/ahf/dns-configure.sh

# If no argument received, run server
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [[ -z "$1" ]]; then
  named -g
else
  exec "$@"
fi
