#!/bin/bash
set -e

DOCKER_DOMAIN=docker.ahf
SYSTEM_NAME=lightcontrol
SHORT_HOST=${SYSTEM_NAME}${SN}
HOST=${SHORT_HOST}.${DOCKER_DOMAIN}

# If no argument received, run
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [[ -z "$1" ]]; then
  rm -f sensor_module_1*
  /tls/generate-signed-cert.sh sensor_module_1 ${HOST} changeit
  java -jar target/lightcontrol-control-1.0-SNAPSHOT.jar \
                      port=${PORT} \
                      shortHost=${SHORT_HOST} \
                      domain=${DOCKER_DOMAIN} \
                      baseUri=https://0.0.0.0:${PORT}/light-control \
                      orchestrationPushServiceName=lc-${PORT}-orch-push \
                      orchestrationPushServiceType=_orch-push-rest-http._tcp \
                      orchestrationPushRelativePath=/orch/push-config \
                      presencePushServiceName=light-control-${SN} \
                      presencePushServiceType=_light-control-rest-http._tcp \
                      presencePushRelativePath=/sensors/presence \
                      trustStoreFile=/tls/cacerts.jks \
                      trustStoreType=jks trustStorePassword=changeit \
                      keyStoreFile=./sensor_module_1.jks \
                      keyStoreType=jks \
                      keyPassword=changeit \
                      serviceDiscoveryEndpoint=http://simpleservicediscovery.${DOCKER_DOMAIN}:8045/servicediscovery \
                      orchestrationEndpoint=https://glassfish.${DOCKER_DOMAIN}:8181/orchestration/store/orchestration \
                      authorisationControlEndpoint=https://glassfish.${DOCKER_DOMAIN}:8181/authorisation-control \
                      lightControllerEndpoint=http://127.0.0.1:8092/light-control/sensors/presence
else
  exec "$@"
fi

