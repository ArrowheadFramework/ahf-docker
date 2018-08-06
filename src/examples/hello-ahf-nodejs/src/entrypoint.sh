#!/bin/sh
set -e

cleanup_handler() {
  echo
  kill -s 2 0
}
trap cleanup_handler 1 2 3 15

#------------------------------
# Defaults
#------------------------------
if [ -z "${IP_CHANGE_POLL_SECONDS}" ]; then
  IP_CHANGE_POLL_SECONDS=5
fi

if [ -z "${SERVER_HOSTNAME}" ]; then
  SERVER_HOSTNAME=hello.docker.ahf
fi

if [ -z "${MAX_DNS_SELF_FAILURES}" ]; then
  MAX_DNS_SELF_FAILURES=5
fi

if [ -z "${DO_DYNAMIC_DNS_UPDATE}" ]; then
  DO_DYNAMIC_DNS_UPDATE=false
fi

if [ -z "${REGISTER_WITH_DNS}" ]; then
  REGISTER_WITH_DNS=true
fi

if [ "${DO_DYNAMIC_DNS_UPDATE}" = true ] && \
   [ "${REGISTER_WITH_DNS}" = false ]; then
   echo "Forced state to REGISTER_WITH_DNS to true because dynamic update was selected."
   REGISTER_WITH_DNS=true
fi

# Require an interface name from which to get the IP if registering with the DNS
if [ "${REGISTER_WITH_DNS}" = true ] &&
   [ -z "${IP_INTERFACE_NAME}" ]; then
  echo "An IP_INTERFACE_NAME is required for DNS registration."
  echo "For example: --env IP_INTERFACE_NAME=eth0"
  exit
fi

# Require an DNS server on which to register
if [ "${REGISTER_WITH_DNS}" = true ] &&
   [ -z "${DNS_SERVER}${BOOTSTRAPPING_PATH}" ]; then
  echo "A DNS_SERVER or a BOOTSTRAPPING_PATH is required for DNS registration."
  echo "For example: --env DNS_SERVER=bind"
  echo "For example: --env DNS_SERVER=172.17.0.1"
  echo "For example: --env BOOTSTRAPPING_PATH=/boots/bootstrap"
  exit
fi

# Require a TSIG file (in the core-utils format) to register with the DNS server
if [ "${REGISTER_WITH_DNS}" = true ] &&
   [ ! -n "$(ls -A /tsig)" ]; then
  echo "You must provide a volume on /tsig containing the necessary TSIG file (i.e. /tsig/tsig)."
  echo "For example: --volume core_tsig:/tsig"
  exit
fi

# Require TLS files given by the core containers
if [ ! -n "$(ls -A /tls)" ]; then
  ls -A /tls
  echo "You must provide a volume on /tls containing the necessary TLS files."
  echo "For example: --volume tls:/tls"
  exit
fi

#------------------------------
# Functions
#------------------------------
test_bootstrapping() {
  test_host=$(echo "${ORCHESTRATION_URL}"| sed -e "s/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/")
  if ! ping -c1 ${test_host} >/dev/null 2>&1 ; then
    echo "Bad bootstrapping, unable to ping orchestration host."
    exit 1
  fi
}

test_dns_for_self() {
  test_host="${SERVER_HOSTNAME}"
  if [ "${reps}" = "${MAX_DNS_SELF_FAILURES}" ]; then
    echo "Testing DNS for self failed too many times. Exiting."
    exit 1
  fi
  if ! ping -c1 ${test_host} >/dev/null 2>&1 ; then
    reps=$((reps + 1))
    update_dns
  else
    reps=0
  fi
}

update_dns() {
  if [ -f "${BOOTSTRAPPING_PATH}" ]; then
    DNS_SERVER=$(cat "${BOOTSTRAPPING_PATH}" | grep -o "^dns:.*" | cut -d" " -f2)
    if [ -n "${DNS_SERVER}" ]; then
      echo "nameserver ${DNS_SERVER}" > /etc/resolv.conf
      test_bootstrapping
    else
      echo "Failed to get a valid DNS server from bootstrapping."
      exit 1
    fi
  fi

  # Register self with the name server for a year
  server_address=$(ip -4 addr show "${IP_INTERFACE_NAME}" | grep "inet" | tail -n 1 | awk '{print $2}' | cut -d"/" -f1)
  tsig_path=/tsig/tsig
  if [ "${REGISTER_WITH_DNS}" = true ]; then
    if [ ! -f ${tsig_path} ]; then
      >&2 echo "To register with the DNS server a TSIG file is required. This file should be mounted on ${tsig_path}."
      >&2 echo "The file should contain two lines, first the key name and then the actual TSIG key."
      exit 1
    else
      # Wait for the DNS server to be up and accepting requests
      while ! nslookup . "${DNS_SERVER}" | grep "Server" >/dev/null 2>&1;
      do
        sleep 2;
      done
      tsig_for_nsupdate=$(sed -n 1p ${tsig_path}):$(sed -n 2p ${tsig_path})
      echo "server ${DNS_SERVER}
update delete ${SERVER_HOSTNAME}
update add ${SERVER_HOSTNAME} 31557600 A ${server_address}
send
" | nsupdate -v -y "${tsig_for_nsupdate}" \
      && echo "Successfully registered with DNS server as ${SERVER_HOSTNAME} on ${server_address}" \
      || >&2 echo "Failed to register with DNS server"
    fi
  fi
}

poll_ip_change(){
  prev_ip=''
  while true; do
    ip=$(ip -4 addr show "${IP_INTERFACE_NAME}" | grep "inet" | tail -n 1 | awk '{print $2}' | cut -d"/" -f1)
    if [ "${ip}" != "${prev_ip}" ]; then
      update_dns
      prev_ip="${ip}"
    fi
    sleep "${IP_CHANGE_POLL_SECONDS}"
    if [ -f "${BOOTSTRAPPING_PATH}" ]; then
      test_bootstrapping
    fi
    if [ "${REGISTER_WITH_DNS}" = true ]; then
      test_dns_for_self
    fi
  done
}

#------------------------------
# Execution
#------------------------------
if [ "${REGISTER_WITH_DNS}" = true ]; then
  update_dns
fi
if [ "${DO_DYNAMIC_DNS_UPDATE}" = true ]; then
  poll_ip_change &
  poll_ip_change_pid=$!
fi

# If no argument received, run server
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [ -z "$1" ]; then
  (node hello-ahf.js \
    --keystorePath=${KEYSTORE_PATH} \
    --keystorePassphrase=${KEYSTORE_PASSPHRASE} \
    --caPemPath=${CA_PEM_PATH} \
    --serviceDiscoveryUrl=${SERVICE_DISCOVERY_URL} \
    --orchestrationUrl=${ORCHESTRATION_URL} \
    --authorisationUrl=${AUTHORISATION_URL} \
    --authorisationControlUrl=${AUTHORISATION_CONTROL_URL}; \
    cleanup_handler) &
    hello_ahf_pid=$!
else
  exec "$@"
fi

if [ "${DO_DYNAMIC_DNS_UPDATE}" = true ]; then
  wait "${poll_ip_change_pid}"
fi
wait "${hello_ahf_pid}"
