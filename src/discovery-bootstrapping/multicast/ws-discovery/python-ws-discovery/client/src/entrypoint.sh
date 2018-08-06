#!/bin/sh
set -e

cleanup_handler() {
  echo 'Got signal, killing all.'
  kill -2 ${pid}
  (sleep 10 && \
  echo "Had to forcibly kill the process after 10 seconds." && \
  kill -9 ${pid}) &
  wait "${pid}"
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
  python ws_discovery_client.py --timeout="${TIMEOUT}" &
else
  exec "$@"
fi

pid=$!
wait "${pid}"