FROM centos:centos6

RUN yum clean all && \
    yum -y update && \
    yum -y install wget java-1.7.0-openjdk-devel && \
    yum clean all

WORKDIR /ahf

RUN wget -q -O SimpleServiceDiscovery.jar https://bitbucket.org/fedeselmer/simpleservicediscovery/raw/8d1f8cdd07a22febf6fc5cae13618d2794ab1a77/SimpleServiceDiscovery.jar && \
    wget -q -O SimpleServiceRegistry.jks https://bitbucket.org/fedeselmer/simpleservicediscovery/raw/8d1f8cdd07a22febf6fc5cae13618d2794ab1a77/SimpleServiceRegistry.jks

RUN yum -y remove wget && \
    yum clean all

ADD ./scripts /ahf
ENTRYPOINT ["/ahf/entrypoint.sh"]

