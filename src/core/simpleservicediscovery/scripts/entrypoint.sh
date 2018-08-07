#!/bin/sh
set -e

if [ -z "${DNS_SERVER}" ] | \
   [ -z "${ORCHESTRATION_URL}" ] | \
   [ -z "${AUTHORISATION_URL}" ]
then
  echo "Necessary environment variables not set."
  echo "Need:"
  echo "DNS_SERVER"
  echo "BROWSING_DOMAIN"
  echo "ORCHESTRATION_URL" 
  echo "AUTHORISATION_URL" 
  exit 1
fi

cleanup_handler() {
  find /out -mindepth 1 -delete
  echo
  killall5 -2
  (sleep 10 && \
  echo "Had to forcibly kill the process after 10 seconds." && \
  killall5 -9) &
}
trap cleanup_handler 1 2 3 15

############################
# Auxiliary functions
############################
update_SERVER_ADDRESS() {
if [ -n "${LISTENING_INTERFACE_NAME}" ]; then
  SERVER_ADDRESS=$(ip -4 addr show "${LISTENING_INTERFACE_NAME}" | grep "inet" | tail -n 1 | awk '{print $2}' | cut -d"/" -f1)
else
  SERVER_ADDRESS=$(ip route get 1 | awk '{print $NF;exit}')
fi
}

wait_for_dns() {
  while ! nslookup . "${DNS_SERVER}" | grep "Server" >/dev/null 2>&1;
  do
    sleep 2;
  done
}

register_with_dns() {
  tsig_for_nsupdate=$(sed -n 1p ${tsig_path}):$(sed -n 2p ${tsig_path})
  echo "server ${DNS_SERVER}
update delete ${SERVER_HOSTNAME}
update add ${SERVER_HOSTNAME} 31557600 A ${SERVER_ADDRESS}
send
" | nsupdate -v -y "${tsig_for_nsupdate}" \
  && echo "Successfully registered with DNS server as ${SERVER_HOSTNAME} on ${SERVER_ADDRESS}" \
  || >&2 echo "Failed to register with DNS server"
}

update_dns_registration_on_ip_change() {
  prev_address="${SERVER_ADDRESS}"
  while true; do
    update_SERVER_ADDRESS
    if [ "${prev_address}" != "${SERVER_ADDRESS}" ]; then
      prev_address="${SERVER_ADDRESS}"
      register_with_dns
    fi
    sleep ${IP_CHANGE_POLL_SECONDS}
  done
}

test_orch () {
  curl -s -o /dev/null -w "%{http_code}" \
       --cert simpleservicediscovery.pem:${keystore_password} \
       --cacert ./dockerca.pem \
       "${ORCHESTRATION_URL}/orchestration/configurations/"
}

############################
# Configuration
############################
if [ -z "${IP_CHANGE_POLL_SECONDS}" ]
then
  IP_CHANGE_POLL_SECONDS=5
fi
if [ -z "${DO_DYNAMIC_DNS_UPDATE}" ]; then
  DO_DYNAMIC_DNS_UPDATE=false
fi

# Get runtime network information
if [ -z "${SERVER_HOSTNAME}" ]; then
  SERVER_HOSTNAME=$(hostname -f)
fi
if [ -z "${SERVER_DOMAIN}" ]; then
  SERVER_DOMAIN=$(hostname -d)
  if [ -z "$SERVER_DOMAIN" ]; then
    SERVER_DOMAIN=docker.ahf
    echo "SERVER_DOMAIN defaulted to ${SERVER_DOMAIN}."
  fi
fi
if [ -z "${SERVER_ADDRESS}" ]; then
  update_SERVER_ADDRESS
fi

tsig_path=/tsig/tsig
keystore_password=changeit

if [ -z "${BROWSING_DOMAIN}" ]
then
  echo "Environment variable BROWSING_DOMAIN not set."
  echo "Assuming ${SERVER_DOMAIN}"
  BROWSING_DOMAIN=${SERVER_DOMAIN}
fi

orchstore_name=orchestration-store._orch-s-ws-https._tcp.srv.${BROWSING_DOMAIN}
authcontrol_name=authorisation-ctrl._auth-ws-https._tcp.srv.docker.ahf.${BROWSING_DOMAIN}


sed -e "s@<dns_server>@${DNS_SERVER}@g" \
  -e "s@<image_hostname>@${SERVER_HOSTNAME}@g" \
  -e "s@<browsing_domain>@${BROWSING_DOMAIN}@g" \
  -e "s@<orchestration_url>@${ORCHESTRATION_URL}@g" \
  -e "s@<authorisation_url>@${AUTHORISATION_URL}@g" \
  SimpleServiceRegistry.properties.template > SimpleServiceRegistry.properties

# Wait for the the glassfish server to signal it is ready
if [ "${WAIT_FOR_TLS_READY}" = true ]
then
  while [ ! -f /tls/ready ];
  do
    sleep 3;
  done
  sleep 5;
fi

# Wait for the DNS server to be up and accepting requests
if [ "${WAIT_FOR_DNS}" = true ]
then
  wait_for_dns
else
  if ! nslookup . "${DNS_SERVER}" | grep "Server" >/dev/null 2>&1; then
    >&2 echo "DNS not responding. If you wish for this container to wait for it, set WAIT_FOR_DNS to true."
    exit 1
  fi
fi

# Register self with the name server for a year
if [ "${REGISTER_WITH_DNS}" = true ]; then
  if [ ! -f ${tsig_path} ]; then
    >&2 echo "To register with the DNS server a TSIG file is required. This file should be mounted on ${tsig_path}."
    >&2 echo "The file should contain two lines, first the key name and then the actual TSIG key."
    exit 1
  fi
  register_with_dns
  if [ "${DO_DYNAMIC_DNS_UPDATE}" = true ]; then
    update_dns_registration_on_ip_change &
    dns_updater_pid=$!
  fi
fi

# Get the orchestration URL from the service registry if possible
if dig +short @${DNS_SERVER} -t ANY "${orchstore_name}" | grep . >/dev/null 2>&1;
then
  orch_host=$(dig +short @${DNS_SERVER} -t ANY "${orchstore_name}" | sed -n 2p | cut -d" " -f4 | sed -E 's/\.$//g')
  orch_path=$(dig +short @${DNS_SERVER} -t ANY "${orchstore_name}" | sed -n 1p | sed -E 's/^"path=(.*)" ".*"$/\1/g' | sed 's@/*$@@g')
  orch_port=$(dig +short @${DNS_SERVER} -t ANY "${orchstore_name}" | sed -n 2p | cut -d" " -f3)
  ORCHESTRATION_URL=https://${orch_host}:${orch_port}${orch_path}
fi

# Wait for the the Certificate Authority (CA) files to be available
if [ "${WAIT_FOR_CA}" = true ]
then
  while [ ! -f /tls/ca.key ];
  do
    sleep 2;
  done
else
  if [ ! -f /tls/ca.key ]; then
    >&2 echo "CA files missing."
    >&2 echo "If you wish for this container to wait for them, set WAIT_FOR_CA to true."
    exit 1
  fi
fi

# Use CA files to generate a signed certificate
mod_canary=$(cat /tls/ca.key | sed -n 5p)
/tls/generate-signed-cert.sh simpleservicediscovery "${SERVER_HOSTNAME}" "${keystore_password}"

# Wait for the the orchestration store to be up and accepting requests
if [ "${WAIT_FOR_ORCH_STORE}" = true ]
then
  while [ "$(test_orch)" != "200" ];
  do
    sleep 2;
    # If the key was changed while we waited, regenerate our certificate.
    # This is in case we had generated our certificates before the core container finished starting and
    # we were using leftovers from an unclean exit.
    if [ "${mod_canary}" != "$(cat /tls/ca.key | sed -n 5p)" ]; then
      /tls/generate-signed-cert.sh simpleservicediscovery "${SERVER_HOSTNAME}" "${keystore_password}"
    fi
  done
else
  if [ "$(test_orch)" != "200" ];
  then
    >&2 echo "Orchestration store not responding."
    >&2 echo "If you wish for this container to wait for it, set WAIT_FOR_ORCH_STORE to true."
    exit 1
  fi
fi

# If no argument received, run server
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [ -z "$1" ]; then
  java -jar SimpleServiceDiscovery.jar &
  pid=$!
  wait "${pid}"
else
  exec "$@"
fi
