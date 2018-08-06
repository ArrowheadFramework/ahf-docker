#!/bin/sh
set -e

cleanup_handler() {
  echo 'Got signal, killing all.'
  kill ${pid}
  (sleep 10 && \
  echo "Had to forcibly kill the process after 10 seconds." && \
  kill -9 ${pid}) &
  wait "${pid}"
}

trap cleanup_handler 1 2 3 15

if [ -z "${SERVICE_NAME}" ] || \
   [ -z "${SERVICE_TYPE}" ] || \
   [ -z "${SERVICE_PORT}" ] || \
   [ -z "${SERVICE_PATH}" ] || \
   [ -z "${NETWORK_INTERFACE}${PUBLISH_HOST}" ] || \
   [ -z "${NETWORK_INTERFACE}${PUBLISH_IP}" ];
then
  echo "This script requires the following environment variables."
  echo
  echo "SERVICE_NAME, current value:      ${SERVICE_NAME}"
  echo "SERVICE_TYPE, current value:      ${SERVICE_TYPE}"
  echo "SERVICE_PORT, current value:      ${SERVICE_PORT}"
  echo "SERVICE_PATH, current value:      ${SERVICE_PATH}"

  echo "You also need either NETWORK_INTERFACE or both PUBLISH_* variables below."
  echo "NETWORK_INTERFACE, current value: ${NETWORK_INTERFACE}"
  echo "PUBLISH_HOST, current value: ${PUBLISH_HOST}"
  echo "PUBLISH_IP, current value: ${PUBLISH_IP}"
  exit
fi

# If no argument received, run server
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [ -z "$1" ]; then
  node node-bonjour-server.js \
           --name="${SERVICE_NAME}" \
           --type="${SERVICE_TYPE}" \
           --port="${SERVICE_PORT}" \
           --path="${SERVICE_PATH}" \
           --host="${PUBLISH_HOST}" \
           --ip="${PUBLISH_IP}" \
           --interface="${NETWORK_INTERFACE}" \
           &
else
  exec "$@"
fi

pid=$!
wait "${pid}"