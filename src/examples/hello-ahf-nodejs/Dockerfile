FROM node:9.3-alpine

RUN apk --no-cache add bind bind-tools

RUN npm install express request fs https tls xml2js minimist --save

WORKDIR /src

COPY src/ .

ENV SERVICE_DISCOVERY_URL=http://simpleservicediscovery.docker.ahf:8045/servicediscovery \
    ORCHESTRATION_URL=https://glassfish.docker.ahf:8181/orchestration/store \
    AUTHORISATION_URL=http://glassfish.docker.ahf:8080/authorisation \
    AUTHORISATION_CONTROL_URL=https://glassfish.docker.ahf:8181/authorisation-control \
    KEYSTORE_PATH=/tls/hello-ahf.p12 \
    KEYSTORE_PASSPHRASE=changeit \
    CA_PEM_PATH=/tls/dockerca.pem

VOLUME /tls

ENTRYPOINT ["./entrypoint.sh"]
