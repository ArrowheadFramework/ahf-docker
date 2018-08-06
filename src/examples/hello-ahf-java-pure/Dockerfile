FROM openjdk:8-jdk-alpine

RUN apk --no-cache add openssl

ENV KEYSTORE_LOCATION=hello.jks \
    CACERTS_LOCATION=ca.jks \
    KEYSTORE_PASSPHRASE=changeit \
    SERVICE_DISCOVERY_URL=http://simpleservicediscovery.docker.ahf:8045/servicediscovery \
    ORCHESTRATION_URL=https://glassfish.docker.ahf:8181/orchestration/store \
    AUTHORISATION_URL=http://glassfish.docker.ahf:8080/authorisation \
    AUTHORISATION_CONTROL_URL=https://glassfish.docker.ahf:8181/authorisation-control \
    AUTHORIZED_CN=client.docker.ahf \
    PORT=8888

EXPOSE ${PORT}
VOLUME /tls

WORKDIR /src
COPY src/ .

RUN javac HelloArrowhead.java

ENTRYPOINT ["./entrypoint.sh"]
