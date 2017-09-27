#!/bin/bash
set -e

while ! nslookup glassfish.docker.ahf ntpd &> /dev/null;
do
  sleep 2;
done

ADMIN_PORT=4848
WEB_PORT=8080
SEC_WEB_PORT=8181
GLASSFISH_HOME=/glassfish3/glassfish/
GLASSFISH_ADMIN=$1
PASSWORD=$2
ADDRESS=`ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{print $1}'`
SERVER_HOSTNAME=`hostname -f`
SERVER_DOMAIN=`hostname -d`
DOMAIN_CONFIG_DIR=$GLASSFISH_HOME/domains/domain1/config


if [[ ! -d /glassfish3/glassfish/domains/domain1/ ]]; then
  if [[ -z "$2" ]]; then
    echo "To initialize this container you must provide an username and a password." >&2
    echo "TODO: Add usage info." 
    exit 1
  fi
  echo "

grant {
     permission java.net.SocketPermission \"localhost:1527\", \"listen,resolve\";
 };
" >> /etc/alternatives/jre/lib/security/java.policy


  echo "AS_ADMIN_PASSWORD="  > chpwdfile
  echo "AS_ADMIN_NEWPASSWORD=$PASSWORD" >> chpwdfile
  echo "AS_ADMIN_PASSWORD=$PASSWORD" > pwdfile
  echo "Glassfish password is $PASSWORD"
  echo "Configuring Glassfish domain, this might take up to a minute..."
  $GLASSFISH_HOME/bin/asadmin create-domain --keytooloptions CN=$SERVER_HOSTNAME --nopassword=true --user=$GLASSFISH_ADMIN domain1

  $GLASSFISH_HOME/bin/asadmin --user $GLASSFISH_ADMIN --passwordfile=./chpwdfile change-admin-password
  $GLASSFISH_HOME/bin/asadmin start-domain
  $GLASSFISH_HOME/bin/asadmin start-database
  GLASSFISH_ASADMIN="$GLASSFISH_HOME/bin/asadmin --user $GLASSFISH_ADMIN --passwordfile=./pwdfile"

  $GLASSFISH_ASADMIN set configs.config.server-config.security-service.auth-realm.certificate.property.assign-groups=peer
  $GLASSFISH_ASADMIN set server-config.ejb-container.ejb-timer-service.property.reschedule-failed-timer=true
  $GLASSFISH_ASADMIN set configs.config.server-config.network-config.protocols.protocol.http-listener-2.ssl.client-auth-enabled=true
  $GLASSFISH_ASADMIN set server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size=50
  $GLASSFISH_ASADMIN set server-config.network-config.protocols.protocol.http-listener-1.http.request-timeout-seconds=-1
  $GLASSFISH_ASADMIN set server-config.network-config.protocols.protocol.http-listener-2.http.request-timeout-seconds=-1
  $GLASSFISH_ASADMIN set server-config.network-config.protocols.protocol.http-listener-2..ssl.cert-nickname=glassfish
  $GLASSFISH_ASADMIN create-jvm-options "-Ddns.server=ntpd:\
-Ddnssd.hostname=glassfish.docker.ahf.:\
-Ddnssd.domain=docker.ahf.:\
-Ddnssd.browsingDomains=docker.ahf.:\
-Ddns.registerDomain=docker.ahf." # NOTE! New versions of core-utils use dnssd.registerDomain instead
                                  #       And both are incompatible (must only use -the correct- one).

  $GLASSFISH_ASADMIN --interactive=false deploy service-registry.ear
  $GLASSFISH_ASADMIN --interactive=false deploy authorisation.ear
  $GLASSFISH_ASADMIN --interactive=false deploy orchestration.ear
  ./install-ssh-keys.sh # TODO: Remove this
  $GLASSFISH_ASADMIN --interactive=false deploy managementtool.war
  rm *.ear
  rm *.war

  $GLASSFISH_ASADMIN --host localhost --port $ADMIN_PORT enable-secure-admin
  rm ./pwdfile
  rm ./chpwdfile
  $GLASSFISH_HOME/bin/asadmin stop-domain

  # Create CA and register it
  rm -f cacerts.jks
  openssl genrsa -des3 -out $DOMAIN_CONFIG_DIR/ca.key -passout pass:changeit 4096
  openssl req -new -x509 -days 365 -key $DOMAIN_CONFIG_DIR/ca.key -out $DOMAIN_CONFIG_DIR/ca.crt -passin pass:changeit -subj "/C=SE/L=Europe/O=ArrowheadFramework/OU=DockerToolsCA/CN=ca.$SERVER_DOMAIN"
  keytool -keystore $DOMAIN_CONFIG_DIR/cacerts.jks -storepass changeit -import -trustcacerts -v -alias dockerca -file $DOMAIN_CONFIG_DIR/ca.crt -noprompt
  
  # Expose the CA certificate, private key and store (with only this CA in it)
  # This is to sign new certificates and recognise certificates signed by this CA
  # Includes a helpful script for signing new certificates and adding them to their own store
  cp -f $DOMAIN_CONFIG_DIR/ca.* /out/
  cp -f $DOMAIN_CONFIG_DIR/cacerts.jks /out/
  cp -f /ahf/generate-signed-cert.sh /out/

  # Also expose in volume so other containers have filesystem-independent access
  cp -f $DOMAIN_CONFIG_DIR/ca.* /tls/
  cp -f $DOMAIN_CONFIG_DIR/cacerts.jks /tls/
  cp -f /ahf/generate-signed-cert.sh /tls/
  
  
  # Use CA to create a signed server certificate
  openssl genrsa -des3 -out $DOMAIN_CONFIG_DIR/glassfish.key -passout pass:changeit 4096
  openssl req -new -key $DOMAIN_CONFIG_DIR/glassfish.key -out $DOMAIN_CONFIG_DIR/glassfish.csr -passin pass:changeit -subj "/C=SE/L=Europe/O=ArrowheadFramework/OU=DockerTools/CN=*.$SERVER_DOMAIN"
  openssl x509 -req -days 365 -in $DOMAIN_CONFIG_DIR/glassfish.csr -CA $DOMAIN_CONFIG_DIR/ca.crt -CAkey $DOMAIN_CONFIG_DIR/ca.key -out $DOMAIN_CONFIG_DIR/glassfish.crt -passin pass:changeit -set_serial 01
  
  # Register the server certificate-key pair
  cat $DOMAIN_CONFIG_DIR/glassfish.crt $DOMAIN_CONFIG_DIR/ca.crt > $DOMAIN_CONFIG_DIR/glassfish-ca.crt
  keytool -import -trustcacerts -alias glassfish -file $DOMAIN_CONFIG_DIR/glassfish-ca.crt -keystore $DOMAIN_CONFIG_DIR/cacerts.jks -storepass changeit -noprompt
  openssl pkcs12 -export -in $DOMAIN_CONFIG_DIR/glassfish-ca.crt -inkey $DOMAIN_CONFIG_DIR/glassfish.key -out $DOMAIN_CONFIG_DIR/glassfish.p12 -name glassfish -CAfile $DOMAIN_CONFIG_DIR/ca.crt -caname "ca" -passin pass:changeit -passout pass:changeit
  keytool -importkeystore -deststorepass changeit -destkeypass changeit -destkeystore $DOMAIN_CONFIG_DIR/keystore.jks -srckeystore $DOMAIN_CONFIG_DIR/glassfish.p12 -srcstoretype PKCS12 -srcstorepass changeit -alias glassfish

fi

$GLASSFISH_HOME/bin/asadmin start-database
$GLASSFISH_HOME/bin/asadmin start-domain -v

exec "$@"
