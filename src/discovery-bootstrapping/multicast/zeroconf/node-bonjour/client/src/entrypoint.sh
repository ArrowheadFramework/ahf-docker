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

if [ -z "${TIMEOUT}" ];
then
  echo "The environment variable TIMEOUT is required."
fi

# If no argument received, run server
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [ -z "$1" ]; then
  timeout -s 2 -t "${TIMEOUT}" \
    node node-bonjour-client.js
else
  exec "$@"
fi
