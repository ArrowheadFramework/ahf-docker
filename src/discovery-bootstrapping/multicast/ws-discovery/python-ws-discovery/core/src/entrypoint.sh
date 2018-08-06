#!/bin/sh
set -e

cleanup_handler() {
  echo 'Got signal, killing all.'
  kill -2 ${pid}
  (sleep 10 && \
  echo "Had to forcibly kill the process after 10 seconds." && \
  kill -9 ${pid}) &
  wait "${pid}"
  killall5
}

trap cleanup_handler 1 2 3 15

if [ -z "${SERVICE_TYPE}" ] || \
   [ -z "${SERVICE_PORT}" ] || \
   [ -z "${SERVICE_PATH}" ] || \
   [ -z "${PUBLISH_INTERVAL}" ] || \
   [ -z "${NETWORK_INTERFACE}${PUBLISH_HOST}" ] || \
   [ -z "${NETWORK_INTERFACE}${PUBLISH_IP}" ];
then
  echo "The following environment variables are required."
  echo
  echo "SERVICE_TYPE, current value:      ${SERVICE_TYPE}"
  echo "SERVICE_PORT, current value:      ${SERVICE_PORT}"
  echo "SERVICE_PATH, current value:      ${SERVICE_PATH}"
  echo "PUBLISH_INTERVAL, current value:  ${PUBLISH_INTERVAL}"

  echo "You also need either NETWORK_INTERFACE or both PUBLISH_* variables below."
  echo "NETWORK_INTERFACE, current value: ${NETWORK_INTERFACE}"
  echo "PUBLISH_HOST, current value: ${PUBLISH_HOST}"
  echo "PUBLISH_IP, current value: ${PUBLISH_IP}"
  exit
fi

if [ -z "${PUBLISH_HOST}" ];
then
  PUBLISH_HOST=$(ip -4 addr show "${NETWORK_INTERFACE}" | grep "inet" | tail -n 1 | awk '{print $2}' | cut -d"/" -f1)
fi

if [ -z "${PUBLISH_IP}" ];
then
  PUBLISH_IP=$(ip -4 addr show "${NETWORK_INTERFACE}" | grep "inet" | tail -n 1 | awk '{print $2}' | cut -d"/" -f1)
fi

address="${SERVICE_TYPE}://${PUBLISH_HOST}:${SERVICE_PORT}${SERVICE_PATH}"

# If no argument received, run server
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [ -z "$1" ]; then
  python ws_discovery_server.py \
           --uri="${address}" \
           --ip="${PUBLISH_IP}" \
           --publishInterval="${PUBLISH_INTERVAL}" \
           &
else
  exec "$@"
fi

pid=$!
wait "${pid}"