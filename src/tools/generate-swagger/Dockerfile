FROM maven:3.5-jdk-8-alpine

ENV DB_USER="root" \
    DB_PASSWORD="temporary-ahf-pass" \
    LOG4J_APPENDER_DB_USER="root" \
    LOG4J_APPENDER_DB_PASSWORD="temporary-ahf-pass"

WORKDIR /ahf

RUN wget -O swagger-ui.zip \
         https://github.com/swagger-api/swagger-ui/archive/master.zip && \
    unzip swagger-ui.zip && \
    rm swagger-ui.zip && \
    mkdir doc && \
    mv swagger-ui*/dist/* doc

RUN wget -O arrowhead-core-src.zip \
         https://github.com/hegeduscs/arrowhead/archive/4.0-lw.zip && \
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
