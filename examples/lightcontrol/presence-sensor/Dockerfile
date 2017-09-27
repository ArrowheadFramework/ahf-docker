FROM maven:3.5.0-jdk-8
#FROM centos:centos6
#
#RUN yum clean all && \
#    yum -y update && \
##    yum -y install openssh openssl openssh-clients && \
#    yum -y install java-1.8.0-openjdk-devel && \
#    yum -y install wget unzip && \
#    yum clean all
#
##RUN wget --no-cookies --no-check-certificate --header "Cookie:oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jdk-8u144-linux-x64.rpm && \
##    rpm -Uvh jdk-8u144-linux-x64.rpm
##RUN alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1
#
#
#RUN wget https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo && \
#    sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo && \
#    yum install -y apache-maven && \
#    yum clean all
#
WORKDIR /ahf
#
#RUN yum -y remove wget unzip && \
#    yum clean all

ADD ./pom.xml /ahf
ADD ./src /ahf/src

RUN mvn clean compile && mvn package

ADD ./scripts /ahf/scripts

ENTRYPOINT ["/ahf/scripts/entrypoint.sh"]

#ADD http://www.random.org/strings/?num=10&len=8&digits=on&upperalpha=on&loweralpha=on&unique=on&format=plain&rnd=new uuid
#RUN rm -rf /glassfish3/glassfish/domains/domain1/

#ENTRYPOINT ["/ahf/entrypoint.sh"]

