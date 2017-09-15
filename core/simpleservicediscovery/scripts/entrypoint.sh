#!/bin/bash
set -e

while [ ! `curl -sL -w "%{http_code}" "http://glassfish:8080/managementtool" -o /dev/null` = "200" ] || [ ! -f /tls/cacerts.jks ];
do
  sleep 3;
done

# TODO: Move this to a template file
echo "# ARROWHEAD MODULE PROPERTIES
# Core Services Discovery
core.server=ntpd
core.domain=docker.ahf
core.hostname=localhost
core.tsig=/tsig/tsig

# Truststore/keystore
truststore.file=/tls/cacerts.jks
truststore.password=changeit
keystore.file=/tls/keystore.jks
keystore.password=changeit

# Authorisation
# Backup URL if not found in SR
authorisation.url=https://glassfish:8181/authorisation

# Orchestration
# Backup URL if not found in SR
orchestration.url=https://glassfish:8181/orchestration/store
# Orchestration Store poll interval
orchestration.monitor.interval=100


# Define supported consumption service types
service.consume.support=\"\"
service.consume.polling.interval=10
simpleservicediscovery.coap.port=5683
simpleservicediscovery.rest.port=8045
simpleservicediscovery.ip=0.0.0.0
" > SimpleServiceRegistry.properties

java -jar SimpleServiceDiscovery.jar

exec "$@"
