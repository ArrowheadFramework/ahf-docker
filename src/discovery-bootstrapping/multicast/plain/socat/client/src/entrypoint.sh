#!/bin/sh
set -e

cleanup_handler() {
  echo 'Got signal, killing all.'
  killall5 -2
  (sleep 10 && \
  echo "Had to forcibly kill the process after 10 seconds." && \
  killall5 -9) &
}

trap cleanup_handler 1 2 3 15

if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ "$1" == "help" ]; then
  echo "Available environment variables: "
  echo
  echo "Multicast parameters"
  echo "------------------------"
  echo "MCAST_GROUP=${MCAST_GROUP}"
  echo "MCAST_UDP_PORT=${MCAST_UDP_PORT}"
fi

# If no multicast group is selected, use default.
if [ -z ${MCAST_GROUP} ]; then
  MCAST_GROUP=224.1.0.1
fi

# If no UDP port is selected, use default.
if [ -z ${MCAST_UDP_PORT} ]; then
  MCAST_UDP_PORT=6666
fi

# If no argument received, run default
# Otherwise, run the arguments received
# Useful for debug, using /bin/sh
if [ -z "$1" ]; then
  result=$(echo | socat STDIO UDP4-DATAGRAM:${MCAST_GROUP}:${MCAST_UDP_PORT})
  echo "${result}"
  if [ -n "${OUTPUT_FILENAME}" ]; then
    echo "${result}" > "/out/${OUTPUT_FILENAME}"
  fi
else
  exec "$@"
fi
