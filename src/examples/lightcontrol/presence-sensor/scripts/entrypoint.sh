#!/bin/bash
set -e

# If no argument received, run
# Otherwise, run the arguments received
# Useful for debug, using /bin/bash
if [[ -z "$1" ]]; then
  rm -f sensor_module_1*
  /tls/generate-signed-cert.sh sensor_module_1 sensor-module-1.docker.ahf changeit
  java -jar target/lightcontrol-sensormodule-1.0-SNAPSHOT.jar \
  -shortHost presencesensor \
  -port ${PORT} \
  -trustStoreFile /tls/cacerts.jks \
  -trustStorePassword changeit \
  -keyStoreFile ./sensor_module_1.jks \
  -keyStorePassword changeit
else
  exec "$@"
fi

