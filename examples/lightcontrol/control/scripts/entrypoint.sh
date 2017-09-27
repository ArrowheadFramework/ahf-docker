#!/bin/bash
set -e

# If no argument received, run
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [[ -z "$1" ]]; then
  rm -f sensor_module_1*
  /tls/generate-signed-cert.sh sensor_module_1 changeit changeit sensor_module_1.docker.ahf /tls/ca.crt /tls/ca.key
  java -jar target/lightcontrol-control-1.0-SNAPSHOT.jar \
                          port=$PORT \
                          shortHost=localhost \
                          domain=docker.ahf \
                          baseUri=http://lightcontrol$SN:$PORT/light-control \
                          orchestrationPushServiceName=lc-$SN-orch-push \
                          orchestrationPushServiceType=_orch-push-rest-http._tcp \
                          orchestrationPushRelativePath=/light-control/orch/push-config \
                          presencePushServiceName=light-control-$SN \
                          presencePushServiceType=_light-control-rest-http._tcp \
                          presencePushRelativePath=/light-control/sensors/presence \
                          trustStoreFile=/tls/cacerts.jks \
                          trustStoreType=jks trustStorePassword=changeit \
                          keyStoreFile=./sensor_module_1.jks \
                          keyStoreType=jks \
                          keyPassword=changeit \
                          serviceDiscoveryEndpoint=http://simpleservicediscovery.docker.ahf:8045/servicediscovery \
                          orchestrationEndpoint=https://glassfish.docker.ahf:8181/orchestration/store/orchestration \
                          lightControllerEndpoint=http://127.0.0.1:8092/light-control/sensors/presence
else
  exec "$@"
fi

