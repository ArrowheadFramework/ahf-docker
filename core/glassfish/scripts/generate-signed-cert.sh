#!/bin/bash

SCRIPT_NAME=`basename "$0"`

if [[ $# -eq 0 ]] ; then
  echo "Provide arguments. TODO: Document"
  echo "Usage:"
  echo "$SCRIPT_NAME name CA-pass out-pass CN CA-crt-path CA-key-path "
  echo ""
  echo "Example:"
  echo "$SCRIPT_NAME sensor_module_1 changeit changeit sensor_module_1.docker.ahf ca.crt ca.key"
  exit 1
fi

NAME=$1
CAPASS=$2
OUTPASS=$3
CN=$4
CACRT=$5
CAKEY=$6


openssl genrsa -des3 -out $NAME.key -passout pass:$OUTPASS 4096
openssl req -new -key $NAME.key -out $NAME.csr -passin pass:$OUTPASS -subj "/C=SE/L=Europe/O=ArroheadFramework/OU=DockerTools/CN=$CN"
openssl x509 -req -days 365 -in $NAME.csr -CA $CACRT -CAkey $CAKEY -out $NAME.crt -passin pass:$CAPASS -set_serial 01

openssl pkcs12 -export -name $NAME -in $NAME.crt -inkey $NAME.key -out $NAME.p12 -passin pass:$OUTPASS -passout pass:$OUTPASS

cat $NAME.crt ca.crt > ${NAME}-ca.crt
openssl pkcs12 -export -in ${NAME}-ca.crt -inkey $NAME.key -out $NAME.p12 -name $NAME -CAfile ca.crt -caname "ca" -passin pass:$OUTPASS -passout pass:$OUTPASS

