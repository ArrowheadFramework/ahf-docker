#!/bin/sh
set -e

# If no argument received, run server
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [ -z "$1" ]; then

  # Handle kill signals
    cleanup_handler() {
    if [ -z ${pid} ]; then
      echo ""
      echo "Got signal before process started, killing all the current processes."
      killall5 -2
      (sleep 10 && \
      echo "Had to forcibly kill the remaining process after 10 seconds." && \
      killall5 -9) &
    else
      echo ""
      echo "Got signal, killing process."
      kill ${pid}
      (sleep 10 && \
      echo "Had to forcibly kill the process after 10 seconds." && \
      kill -9 ${pid}) &
      wait "${pid}"
    fi
    }
  trap cleanup_handler 1 2 3 15

  # This application requires TLS files given by the core containers
  if [ ! -n "$(ls -A /tls)" ]; then
    ls -A /tls
    echo "You must provide a volume on /tls containing the necessary TLS files."
    exit
  fi

  # Generate the necessary TLS certificates for this container and its clients
  keytool -import \
        -trustcacerts \
        -alias "ca" \
        -file "/tls/ca.crt" \
        -keystore "ca.jks" \
        -storepass "changeit" \
        -noprompt

  /tls/generate-signed-cert.sh hello hello.docker.ahf changeit
  /tls/generate-signed-cert.sh client client.docker.ahf changeit
  mkdir -p /client
  cp -f client* /tls/ca.crt /client

  # Start the actual application
  java \
    -DkeystoreLocation=${KEYSTORE_LOCATION} \
    -DcacertsLocation=${CACERTS_LOCATION} \
    -DkeystorePassphrase=${KEYSTORE_PASSPHRASE} \
    -DserviceDiscoveryUrl=${SERVICE_DISCOVERY_URL} \
    -DorchestrationUrl=${ORCHESTRATION_URL} \
    -DauthorisationUrl=${AUTHORISATION_URL} \
    -DauthorisationControlUrl=${AUTHORISATION_CONTROL_URL} \
    -DauthorizedCn=${AUTHORIZED_CN} \
    -Dhostname=$(hostname -f) \
    -Dport=${PORT} \
    HelloArrowhead &
  pid=$!
  wait "${pid}"

else
  exec "$@"
fi
