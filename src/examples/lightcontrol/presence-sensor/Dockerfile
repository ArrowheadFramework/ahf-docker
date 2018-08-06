FROM maven:3.5.0-jdk-8

WORKDIR /ahf

COPY pom.xml .
COPY src/ src/

RUN mvn -q clean compile && mvn -q package

COPY scripts /ahf/scripts

ENTRYPOINT ["scripts/entrypoint.sh"]

