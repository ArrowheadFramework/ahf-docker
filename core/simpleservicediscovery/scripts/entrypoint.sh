#!/bin/bash
set -e

sleep 2
while [ ! -f /tsig/tsig ]
do
  sleep 2
done

# TODO: Move this to a template file
echo "# ARROWHEAD MODULE PROPERTIES
# Core Services Discovery
core.server=ntpd
core.domain=docker.ahf
core.hostname=localhost
core.tsig=/tsig/tsig

# Truststore/keystore
truststore.file=./SimpleServiceRegistry.jks
truststore.password=abc1234
keystore.file=./SimpleServiceRegistry.jks
keystore.password=abc1234

# Authorisation
# Backup URL if not found in SR
authorisation.url=https://glassfish:8181/authorisation-control

# Orchestration
# Backup URL if not found in SR
orchestration.url=https://glassfish:8181/orchestration-store
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
