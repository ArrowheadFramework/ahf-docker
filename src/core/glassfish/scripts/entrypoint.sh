#!/bin/sh
set -e

############################
# Singal handling
############################
signal_handler() {
  kill -- -1
}
trap signal_handler 1 2 3 15

############################
# Auxiliary functions
############################
clean_glassfish() {
  rm -f "${DOMAIN_CONFIG_DIR}/ready"
  find "${GLASSFISH_HOME}/databases/" -mindepth 1 -delete
}

clean_tls() {
  find "/tls/" -mindepth 1 -delete
  find "/out/" -mindepth 1 -delete
}

update_SERVER_ADDRESS() {
if [ -n "${LISTENING_INTERFACE_NAME}" ]; then
  SERVER_ADDRESS=$(ip -4 addr show "${LISTENING_INTERFACE_NAME}" | grep "inet" | tail -n 1 | awk '{print $2}' | \
                                                                   cut -d"/" -f1)
else
  SERVER_ADDRESS=$(ip route get 1 | awk '{print $NF;exit}')
fi
}

build_tls() {
  clean_tls
  # Create new CA and put it in a trust store
  openssl genrsa \
            -des3 \
            -out "/tls/ca.key" \
            -passout "pass:${KEYSTORE_PASSWORD}" \
            4096
  openssl req \
            -new \
            -x509 \
            -days 365 \
            -key "/tls/ca.key" \
            -out "/tls/ca.crt" \
            -passin "pass:${KEYSTORE_PASSWORD}" \
            -subj "/C=SE/L=Europe/O=ArrowheadFramework/OU=DockerToolsCA/CN=ca.$SERVER_DOMAIN"
  keytool -import -trustcacerts -noprompt -v \
          -keystore "/tls/cacerts.jks" \
          -storepass "${KEYSTORE_PASSWORD}" \
          -alias dockerca \
          -file "/tls/ca.crt"

  # Build a script for using the CA to generate signed certificates
  sed -e "s/<ca_pass>/${KEYSTORE_PASSWORD}/g" \
      -e "s/<cacrt_filename>/ca.crt/g" \
      -e "s/<cakey_filename>/ca.key/g" \
      generate-signed-cert.template > /tls/generate-signed-cert.sh
  chmod +x /tls/generate-signed-cert.sh

  # Generate a client certificate for allowing quick tests ran from outside
  cd /tls/
  ./generate-signed-cert.sh tester "tester.${SERVER_DOMAIN}" "${TESTER_KEYSTORE_PASSWORD}"
  mv -f tester.jks /out/
  rm -f ./tester*
  cd - < /dev/null

  # Use CA to create a signed server certificate
  mkdir temp
  openssl genrsa \
            -des3 \
            -out "./temp/glassfish.key" \
            -passout "pass:${KEYSTORE_PASSWORD}" \
            4096
  openssl req \
            -new \
            -key "./temp/glassfish.key" \
            -out "./temp/glassfish.csr" \
            -passin "pass:${KEYSTORE_PASSWORD}" \
            -subj "/C=SE/L=Europe/O=ArrowheadFramework/OU=DockerTools/CN=*.${SERVER_DOMAIN}"
  openssl x509 \
            -req \
            -days 365 \
            -in "./temp/glassfish.csr" \
            -CA "/tls/ca.crt" \
            -CAkey "/tls/ca.key" \
            -out "./temp/glassfish.crt" \
            -passin "pass:${KEYSTORE_PASSWORD}" \
            -set_serial 01

  # Register the server certificate-key pair
  cat "./temp/glassfish.crt" "/tls/ca.crt" > "./temp/glassfish-ca.crt"
  keytool -import -trustcacerts -noprompt \
          -alias glassfish \
          -file "./temp/glassfish-ca.crt" \
          -keystore "/tls/cacerts.jks" \
          -storepass "${KEYSTORE_PASSWORD}"
  openssl pkcs12 \
            -export \
            -in "./temp/glassfish-ca.crt" \
            -inkey "./temp/glassfish.key" \
            -out "./temp/glassfish.p12" \
            -name glassfish \
            -CAfile "/tls/ca.crt" \
            -caname "ca" \
            -passin "pass:${KEYSTORE_PASSWORD}" \
            -passout "pass:${KEYSTORE_PASSWORD}"
  keytool -importkeystore \
          -deststorepass "${KEYSTORE_PASSWORD}" \
          -destkeypass "${KEYSTORE_PASSWORD}" \
          -destkeystore "/tls/keystore.jks" \
          -srckeystore "./temp/glassfish.p12" \
          -srcstoretype PKCS12 \
          -srcstorepass "${KEYSTORE_PASSWORD}" \
          -alias glassfish
  rm -rf ./temp

  touch "/tls/ready"
}

############################
# Configuration
############################
tsig_path=/tsig/tsig
if [ -z "${KEYSTORE_PASSWORD}" ]
then
  KEYSTORE_PASSWORD=changeit
fi
if [ -z "${TESTER_KEYSTORE_PASSWORD}" ]
then
  TESTER_KEYSTORE_PASSWORD=changeit
fi

if [ -z "${IP_CHANGE_POLL_SECONDS}" ]
then
  IP_CHANGE_POLL_SECONDS=5
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

if [ -z "${DO_DYNAMIC_DNS_UPDATE}" ]; then
  DO_DYNAMIC_DNS_UPDATE=false
fi

# Set JVM options used by the core services
# NOTE! New versions of core-utils use dnssd.registerDomain instead
#       And both are incompatible (must only use -the correct- one).
jvm_opts="-Ddns.server=${DNS_SERVER}:\
-Ddnssd.hostname=${SERVER_HOSTNAME}.:\
-Ddnssd.domain=${SERVER_DOMAIN}.:\
-Ddnssd.browsingDomains=${SERVER_DOMAIN}.:\
-Ddns.registerDomain=${SERVER_DOMAIN}."


############################
# Auxiliary commands
############################
# Clean state files if requested
if [ "$1" = "clean" ]; then
  clean_glassfish
  clean_tls
  exit
fi

# Build TLS if requested
if [ "$1" = "tls" ]; then
  build_tls
  exit
fi

############################
# Pre-requisites
############################
if [ -z "${DNS_SERVER}" ]
then
  echo "DNS_SERVER environment variable not set."
  exit 1
fi

############################
# TLS configuration
############################
# Build TLS certificates if necessary
if [ ! -f "/tls/ready" ]; then
  build_tls
fi

# Use the trust and key stores from the /tls/ folder
cp -f "/tls/cacerts.jks" "${DOMAIN_CONFIG_DIR}"
cp -f "/tls/keystore.jks" "${DOMAIN_CONFIG_DIR}"

# Expose the CA certificate, private key and store (with only this CA in it)
# This is to sign new certificates and recognise certificates signed by this CA
# Includes a helpful script for signing new certificates and adding them to their own store
cp -f /tls/cacerts.jks \
     /tls/generate-signed-cert.sh         \
     /tls/ca.key                          \
     /tls/ca.crt                          \
     /out/
if [ "${LOCK_OUT_DIR}" = "false" ] || [ "${LOCK_OUT_DIR}" = "FALSE" ]; then
  chmod -R 777 /out/
else
  chmod -R 000 /out/
fi

############################
# Glassfish configuration
############################
# Wait for the DNS server to be up and accepting requests
wait_for_dns() {
  while ! nslookup . "${DNS_SERVER}" | grep "Server" >/dev/null 2>&1;
  do
    sleep 2;
  done
}

update_dns() {
  tsig_for_nsupdate=$(sed -n 1p ${tsig_path}):$(sed -n 2p ${tsig_path})
  echo "server ${DNS_SERVER}
update delete ${SERVER_HOSTNAME}
update add ${SERVER_HOSTNAME} 31557600 A ${SERVER_ADDRESS}
send
" | nsupdate -v -y "${tsig_for_nsupdate}" \
  && echo "Successfully registered with DNS server as ${SERVER_HOSTNAME} on ${SERVER_ADDRESS}" \
  || >&2 echo "Failed to register with DNS server"
}

update_dns_on_ip_change() {
  prev_address="${SERVER_ADDRESS}"
  while true; do
    update_SERVER_ADDRESS
    if [ "${prev_address}" != "${SERVER_ADDRESS}" ]; then
      prev_address="${SERVER_ADDRESS}"
      update_dns
    fi
    sleep ${IP_CHANGE_POLL_SECONDS}
  done
}

wait_for_dns

# Register self with the name server for a year
if [ "${REGISTER_WITH_DNS}" = true ]; then
    if [ ! -f ${tsig_path} ]; then
      >&2 echo "To register with the DNS server a TSIG file is required. This file should be mounted on ${tsig_path}."
      >&2 echo "The file should contain two lines, first the key name and then the actual TSIG key."
      exit 1
    fi
    update_dns
    if [ "${DO_DYNAMIC_DNS_UPDATE}" = true ]; then
      update_dns_on_ip_change &
      dns_updater_pid=$!
    fi
fi



if [ ! -f "${DOMAIN_CONFIG_DIR}/ready" ] || \
   [ ! -f "${GLASSFISH_HOME}/databases/ready" ]; then

  printf "%s\n" "Configuring the Glassfish domain..."
  # If there is no current configuration, initialize the server
  clean_glassfish

  # Make glassfish use our certificate for all of its interfaces
  # TODO: Can we disable interfaces we are not using, like CORBA?
  sed -i "s/s1as/glassfish/g" /glassfish3/glassfish/domains/domain1/config/*.xml

  # Use the selected admin username and password
  if [ ! -f "pwdfile" ]; then
    printf "%s\n" "AS_ADMIN_PASSWORD="  > chpwdfile
    printf "%s\n" "AS_ADMIN_NEWPASSWORD=$GLASSFISH_PASSWORD" >> chpwdfile
    printf "%s\n" "AS_ADMIN_PASSWORD=$GLASSFISH_PASSWORD" > pwdfile
  fi
  printf "%s\n" "Glassfish password is $GLASSFISH_PASSWORD"
  asadmin="$GLASSFISH_HOME/bin/asadmin"
  sed -Ei "s/^admin;/$GLASSFISH_ADMIN;/g" ${DOMAIN_CONFIG_DIR}/admin-keyfile
  ${asadmin} --user "$GLASSFISH_ADMIN" --passwordfile=./chpwdfile change-admin-password 2>/dev/null|| \
  echo "Password already set previously. Using last password. Please use a clean configuration if you need to reset it."
  asadmin="$GLASSFISH_HOME/bin/asadmin --user $GLASSFISH_ADMIN --passwordfile=./pwdfile"

  ${asadmin} start-domain -v &
  pid=$!
  ${asadmin} start-database

  # Wait for the domain which, in the background, might not have started yet
  while [ -n "$(${asadmin} list-domains | grep -i 'Not running')" ]; do
    sleep 1
  done

  if [ "${SECURE_GLASSFISH}" = true ]; then
    # Make the Glassfish administration use secure connections
    ${asadmin} enable-secure-admin --adminalias glassfish --instancealias glassfish
    ${asadmin} stop-domain
    ${asadmin} start-domain -v &
    pid=$!
  fi

  # Wait for the domain which, in the background, might not have started yet
  while [ -n "$(${asadmin} list-domains | grep -i 'Not running')" ]; do
    sleep 1
  done

  ${asadmin} create-jvm-options "${jvm_opts}"

  # Deploy, but only once. Reduces space and start-up time after initial run.
  # TODO: Test extensively. Do environment changes require re-deployment?
  if [ -f authorisation.ear ]; then
    ${asadmin} --interactive=false deploy ./authorisation.ear
    rm ./authorisation.ear
  fi
  if [ -f orchestration.ear ]; then
    ${asadmin} --interactive=false deploy ./orchestration.ear
    rm ./orchestration.ear
  fi
  rm ./pwdfile ./chpwdfile

  touch "${DOMAIN_CONFIG_DIR}/ready" \
        "${GLASSFISH_HOME}/databases/ready"
else
  # Start the server with the previous configuration
  "${GLASSFISH_HOME}/bin/asadmin" start-database
  "${GLASSFISH_HOME}/bin/asadmin" start-domain -v &
  pid=$!
fi

wait "${pid}"

exec "$@"
