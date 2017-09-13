FROM centos:centos6

RUN yum clean all && \
    yum -y update && \
    yum -y install iproute && \
    yum -y install openssh openssl openssh-clients && \
    yum -y install wget unzip java-1.7.0-openjdk-devel && \
    yum clean all

ENV ADMIN_PORT=4848 \
    WEB_PORT=8080 \
    SEC_WEB_PORT=8181 \
    GLASSFISH_HOME=/glassfish4/glassfish/

# The core-services provided make use of things not available in Glassfish 4
#RUN wget -q http://download.oracle.com/glassfish/4.1.2/release/glassfish-4.1.2.zip && \
#    unzip -q glassfish-4.1.2.zip && \
#    rm -f glassfish-4.1.2.zip && \
#    rm -rf /glassfish4/glassfish/domains/domain1/
    
RUN wget -q http://download.oracle.com/glassfish/3.1.2.2/release/glassfish-3.1.2.2.zip && \
    unzip -q glassfish-3.1.2.2.zip && \
    rm -f glassfish-3.1.2.2.zip && \
    rm -rf /glassfish3/glassfish/domains/domain1/

WORKDIR /ahf

RUN wget -q -O authorisation.ear https://github.com/fernando-ltu/ahf-docker/blob/master/core/glassfish/core-services/authorisation-application-1.2.ear?raw=true && \
    wget -q -O managementtool.war https://github.com/fernando-ltu/ahf-docker/blob/master/core/glassfish/core-services/managementtool-1.2.5.war?raw=true && \
    wget -q -O orchestration.ear https://github.com/fernando-ltu/ahf-docker/blob/master/core/glassfish/core-services/orchestration-application-1.1.ear?raw=true && \
    wget -q -O service-registry.ear https://github.com/fernando-ltu/ahf-docker/blob/master/core/glassfish/core-services/service-registry-application-1.1.2.ear?raw=true

RUN yum -y remove wget unzip && \
    yum clean all

ADD ./scripts /ahf
ENTRYPOINT ["/ahf/entrypoint.sh"]

