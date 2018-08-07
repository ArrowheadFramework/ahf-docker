FROM openjdk:7-jdk

ENV ADMIN_PORT=4848 \
    WEB_PORT=8080 \
    SEC_WEB_PORT=8181 \
    GLASSFISH_HOME=/glassfish3/glassfish/ \
    GLASSFISH_VERSION=3.1.2.2 \
    GLASSFISH_ADMIN=admin \
    REGISTER_WITH_DNS=true \
    GLASSFISH_PASSWORD=pass \
    KEYSTORE_PASSWORD=changeit \
    TESTER_KEYSTORE_PASSWORD=changeit \
    JAVA_POLICY_PATH="/etc/java-7-openjdk/security/java.policy" \
    DOMAIN_CONFIG_DIR="/glassfish3/glassfish/domains/domain1/config"


RUN apt-get update && apt-get install -y --no-install-recommends \
        dnsutils \
        iproute \
    && rm -rf /var/lib/apt/lists/*

RUN wget http://download.oracle.com/glassfish/${GLASSFISH_VERSION}/release/glassfish-${GLASSFISH_VERSION}.zip && \
    unzip -q glassfish-${GLASSFISH_VERSION}.zip && \
    rm -f glassfish-${GLASSFISH_VERSION}.zip

WORKDIR /ahf

# Ideally we will get the code for these and build them from the sources in the future.
# For a shorter term, it will also be important to move them out of GitHub.
RUN wget -O authorisation.ear \
    https://github.com/fernando-ltu/ahf-docker/blob/aca3eb18d673b7e5a682346fd22dd2e486ea5dab/core/glassfish/core-services/authorisation-application-1.2.ear?raw=true && \
    wget -O managementtool.war \
    https://github.com/fernando-ltu/ahf-docker/blob/aca3eb18d673b7e5a682346fd22dd2e486ea5dab/core/glassfish/core-services/managementtool-1.2.5.war?raw=true && \
    wget -O orchestration.ear \
    https://github.com/fernando-ltu/ahf-docker/blob/aca3eb18d673b7e5a682346fd22dd2e486ea5dab/core/glassfish/core-services/orchestration-application-1.1.ear?raw=true && \
    wget -O service-registry.ear \
    https://github.com/fernando-ltu/ahf-docker/blob/aca3eb18d673b7e5a682346fd22dd2e486ea5dab/core/glassfish/core-services/service-registry-application-1.1.2.ear?raw=true

COPY scripts/glassfish-setup.sh scripts/glassfish.properties ./
RUN ./glassfish-setup.sh

COPY scripts/ .

VOLUME /tls /tsig /out

ENTRYPOINT ["./entrypoint.sh"]

