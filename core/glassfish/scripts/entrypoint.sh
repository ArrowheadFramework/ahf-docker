#!/bin/bash
set -e

ADMIN_PORT=4848
WEB_PORT=8080
SEC_WEB_PORT=8181
GLASSFISH_HOME=/glassfish3/glassfish/
GLASSFISH_ADMIN=$1
PASSWORD=$2
SERVER_HOSTNAME=`hostname -f`


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
  $GLASSFISH_ASADMIN delete-auth-realm certificate
  $GLASSFISH_ASADMIN create-auth-realm --classname com.sun.enterprise.security.auth.realm.certificate.CertificateRealm --property assign-groups=peer certificate
  $GLASSFISH_ASADMIN delete-ssl --type http-listener http-listener-2
  $GLASSFISH_ASADMIN create-ssl --certname s1as --type http-listener --ssl3enabled=true --tlsenabled=true --clientauthenabled=true http-listener-2
  $GLASSFISH_ASADMIN set server-config.ejb-container.ejb-timer-service.property.reschedule-failed-timer=true
  $GLASSFISH_ASADMIN set server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size=50
  $GLASSFISH_ASADMIN set server-config.network-config.protocols.protocol.http-listener-1.http.request-timeout-seconds=-1
  $GLASSFISH_ASADMIN set server-config.network-config.protocols.protocol.http-listener-2.http.request-timeout-seconds=-1
  $GLASSFISH_ASADMIN create-jvm-options "-Ddns.server=ntpd:\
-Ddnssd.hostname=glassfish.docker.ahf.:\
-Ddnssd.domain=docker.ahf.:\
-Ddnssd.browsingDomains=docker.ahf.:\
-Ddns.registerDomain=docker.ahf." # NOTE! New versions of core-utils use dnssd.registerDomain instead
                                  #       And both are incompatible (must only use -the correct- one).

  $GLASSFISH_ASADMIN --interactive=false deploy service-registry.ear
  $GLASSFISH_ASADMIN --interactive=false deploy authorisation.ear
  $GLASSFISH_ASADMIN --interactive=false deploy orchestration.ear
  ./install-ssh-keys.sh
  $GLASSFISH_ASADMIN --interactive=false deploy managementtool.war
  rm *.ear
  rm *.war

  $GLASSFISH_ASADMIN --host localhost --port $ADMIN_PORT enable-secure-admin
  rm ./pwdfile
  rm ./chpwdfile
  $GLASSFISH_HOME/bin/asadmin stop-domain
fi

$GLASSFISH_HOME/bin/asadmin start-database
$GLASSFISH_HOME/bin/asadmin start-domain -v

exec "$@"
