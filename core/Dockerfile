FROM maven:3.5-jdk-8-alpine AS build

WORKDIR /ahf

RUN wget -O arrowhead-core-src.zip \
         https://github.com/hegeduscs/arrowhead/archive/4.0-lw.zip && \
    unzip arrowhead-core-src.zip && \
    rm arrowhead-core-src.zip && \
    cd arrowhead* && \
    mvn clean package
RUN mv arrowhead*/target/config . && \
    mv arrowhead*/target/arrowhead_core-4.0-lw.jar . && \
    mv config/app.properties.sample config/app.properties && \
    mv config/log4j.properties.sample config/log4j.properties && \
    rm -rf arrowhead*/

FROM openjdk:8-alpine

EXPOSE 8440

RUN apk add --update mysql mysql-client && \
    rm -f /var/cache/apk/*

WORKDIR /ahf

ARG default_db_user=ahf
ARG default_db_pass=changeit

ENV DB_USER=$default_db_user \
    DB_PASSWORD=$default_db_pass \
    LOG4J_APPENDER_DB_USER=$default_db_user \
    LOG4J_APPENDER_DB_PASSWORD=$default_db_pass

COPY --from=build /ahf /ahf

COPY scripts/util.sh .

COPY db_init/ .
COPY scripts/mysql_config.sh .
RUN ./mysql_config.sh

COPY scripts/entrypoint.sh .
ENTRYPOINT ["./entrypoint.sh"]
