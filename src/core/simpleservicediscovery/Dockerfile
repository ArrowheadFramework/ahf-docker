FROM openjdk:7-jdk-alpine

ENV WAIT_FOR_ORCH_STORE=true \
    WAIT_FOR_TLS_READY=true \
    REGISTER_WITH_DNS=true

RUN apk --no-cache add bind-tools openssl curl

WORKDIR /ahf

RUN curl -O \
    https://bitbucket.org/fedeselmer/simpleservicediscovery/raw/8d1f8cdd07a22febf6fc5cae13618d2794ab1a77/SimpleServiceDiscovery.jar

COPY scripts/ .
COPY SimpleServiceRegistry.properties.template .

VOLUME /tls /tsig

ENTRYPOINT ["./entrypoint.sh"]

