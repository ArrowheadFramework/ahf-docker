FROM maven:3.5-jdk-8-alpine

ENV DB_USER="root" \
    DB_PASSWORD="temporary-ahf-pass" \
    LOG4J_APPENDER_DB_USER="root" \
    LOG4J_APPENDER_DB_PASSWORD="temporary-ahf-pass"

WORKDIR /ahf

RUN wget -O arrowhead-core-src.zip \
         https://github.com/hegeduscs/arrowhead/archive/e3f76f405d358a20eea755e2a074fb407f773230.zip && \
    unzip arrowhead-core-src.zip && \
    rm arrowhead-core-src.zip

COPY jaxrs-analyzer-maven-plugin.xml .

RUN cd arrowhead* && \
    mvn clean package

RUN cd arrowhead* && \
    sed \
    -e '/<plugins>/ {' -e 'r ../jaxrs-analyzer-maven-plugin.xml' -e 'd' -e '}' \
    -i pom.xml

RUN cd arrowhead* && \
    mvn package

COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]
