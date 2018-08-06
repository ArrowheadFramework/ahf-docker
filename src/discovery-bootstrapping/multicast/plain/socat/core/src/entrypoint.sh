#!/bin/sh
#set -e

#------------------------------
# Pending
#------------------------------
#TODO: Clear variables to ignore for UPDATE_ON_IP_CHANGE and print their names.
#TODO: Uncomment `#set -e`. Temporary measure because `killall socat` returns non-zero code. Investigate.

#------------------------------
# Defaults
#------------------------------
if [ -z "${IP_CHANGE_POLL_SECONDS}" ]; then
  IP_CHANGE_POLL_SECONDS=5
fi

if [ -z  "${UPDATE_ON_IP_CHANGE}" ]; then
  UPDATE_ON_IP_CHANGE=false
  echo "Dynamically updating information on IP change. Some environment variables will be replaced accordingly."
fi

cleanup_handler() {
  echo
  killall5 -2
  (sleep 10 && \
  echo "Had to forcibly kill the process after 10 seconds." && \
  killall5 -9) &
}

trap cleanup_handler 1 2 3 15

publish() {
  echo "Publishing ${URI} on interface ${MCAST_INTERFACE}, multicast group: ${MCAST_GROUP}, port: ${MCAST_UDP_PORT}"
  socat UDP4-RECVFROM:${MCAST_UDP_PORT},ip-add-membership=${MCAST_GROUP}:${MCAST_INTERFACE},fork \
        SYSTEM:"echo \"${URI}\" \"${IP_ADDRESS}\""
}

poll_changes() {
  echo entered poll_changes
  prev_address="${IP_ADDRESS}"
  while true; do
    update_IP_ADDRESS
    if [ "${prev_address}" != "${IP_ADDRESS}" ]; then
      killall socat
      prev_address="${IP_ADDRESS}"
      update_MCAST_INTERFACE
      update_URI_HOST
      update_URI
      wait "${publish_pid}"
      publish &
      publish_pid=$!
    fi
    sleep ${IP_CHANGE_POLL_SECONDS}
  done
}

update_IP_ADDRESS() {
  # If we are not given an IP address to publish, we form it using the available information.
  if [ -n "${PUBLISH_INTERFACE_NAME}" ]; then
    IP_ADDRESS=$(ip -4 addr show "${PUBLISH_INTERFACE_NAME}" | grep "inet" | tail -n 1 | awk '{print $2}' | \
                                                               cut -d"/" -f1)
  else
    IP_ADDRESS=$(ip route get 1 | awk '{print $NF;exit}')
  fi
}

update_MCAST_INTERFACE() {
  if [ -n "${MCAST_INTERFACE_NAME}" ]; then
    MCAST_INTERFACE=$(ip -4 addr show "${MCAST_INTERFACE_NAME}" | grep "inet" | tail -n 1 | awk '{print $2}' | \
                                                                  cut -d"/" -f1)
  else
    MCAST_INTERFACE="0.0.0.0"
  fi
}

update_URI_HOST(){
  if [ -n "${PUBLISH_INTERFACE_NAME}" ]; then
    URI_HOST=$(ip -4 addr show "${PUBLISH_INTERFACE_NAME}" | grep "inet" | tail -n 1 | awk '{print $2}' | \
                                                             cut -d"/" -f1)
  else
    URI_HOST=$(ip route get 1 | awk '{print $NF;exit}')
  fi
}

update_URI(){
  URI="${URI_HOST}"

  if [ -n "${URI_SCHEME}" ]; then
    URI="${URI_SCHEME}://${URI}"
  fi

  if [ -n "${URI_PORT}" ]; then
    URI="${URI}:${URI_PORT}"
  fi

  if [ -n "${URI_PATH}" ]; then
    URI="${URI}${URI_PATH}"
  fi
}


if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
  echo "Available environment variables: "
  echo
  echo "Data to publish"
  echo "------------------------"
  echo "URI=${URI}"
  echo "URI_SCHEME=${URI_SCHEME}"
  echo "URI_HOST=${URI_HOST}"
  echo "URI_PORT=${URI_PORT}"
  echo "URI_PATH=${URI_PATH}"
  echo "IP_ADDRESS=${IP_ADDRESS}"
  echo
  echo "PUBLISH_INTERFACE_NAME=${PUBLISH_INTERFACE_NAME}"
  echo
  echo
  echo "Interface to publish on"
  echo "------------------------"
  echo "MCAST_INTERFACE=${MCAST_INTERFACE}"
  echo "MCAST_INTERFACE_NAME=${MCAST_INTERFACE_NAME}"
  echo "MCAST_GROUP=${MCAST_GROUP}"
  echo "MCAST_UDP_PORT=${MCAST_UDP_PORT}"
fi

if [ -z "${IP_ADDRESS}" ]; then
  update_IP_ADDRESS
fi

# If we are not given a URI to publish, we form it using the available information.
if [ -z "${URI}" ]; then
  if [ -z "${URI_HOST}" ]; then
    update_URI_HOST
  fi
  update_URI
fi

# Determine which interface to publish on based on the available information.
if [ -z "${MCAST_INTERFACE}" ]; then
  update_MCAST_INTERFACE
fi

# If no multicast group is selected, use default.
if [ -z "${MCAST_GROUP}" ]; then
  MCAST_GROUP=224.1.0.1
fi

# If no UDP port is selected, use default.
if [ -z "${MCAST_UDP_PORT}" ]; then
  MCAST_UDP_PORT=6666
fi


# If no argument received, run server
# Otherwise, run the arguments received
# Useful for debug, using /bin/sh
if [ -z "$1" ]; then
  publish &
  publish_pid=$!
  if [ "${UPDATE_ON_IP_CHANGE}" = true ]; then
    poll_changes &
    poll_changes_pid=$!
    wait "${poll_changes_pid}"
  fi
else
  exec "$@"
fi

wait "${publish_pid}"
