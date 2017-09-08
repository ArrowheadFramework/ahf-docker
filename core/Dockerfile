FROM centos:centos6

RUN yum -y update; yum clean all
RUN yum -y install bind iproute; yum clean all
#RUN yum -y install e2fsprogs; yum clean all
#RUN yum -y install java-1.7.0-openjdk; yum clean all
RUN yum -y install ntp; yum clean all
RUN yum -y install openssh openssl openssh-clients; yum clean all
#RUN yum -y install wget unzip; yum clean all
#RUN chkconfig named on

WORKDIR /ahf

ADD ./scripts /ahf
ADD ./packages /ahf

ARG CACHE_DATE=2016-01-01
ENV DOCKER_SHORT_HOSTNAME host
ENV DOCKER_DOMAIN docker.ahf
ENV DOCKER_HOSTNAME host.docker.ahf
ENV GLASSFISH_PASSWORD useconfigfile
ENV GLASSFISH_PASSWORD_BASE64 dXNlY29uZmlnZmlsZQ==
#EXPOSE 8080
#EXPOSE 8181
#EXPOSE 53
#EXPOSE 123
RUN ./interactive_setup.sh
# TODO: Move ssh key generation out and just copy
#RUN ./install-ssh-keys.sh


#RUN ADDRESS=`ifconfig | grep 'inet addr:' | grep -v '127.0.0.1' | cut -d: -f2 | awk '{print $1}'`
#RUN echo nameserver $ADDRESS > /etc/resolv.conf

#RUN ./install-ntp-server.sh

#RUN rpm -Uvh jdk-7u25-linux-x64.rpm
#RUN rpm -Uvh glassfish-3.1.2.2-4.noarch.rpm
#RUN ./install-glassfish.sh
#RUN rpm -Uvh ServiceRegistry-1.1.2-1.noarch.rpm
#RUN rpm -Uvh Authorisation-1.2-1.noarch.rpm
#RUN rpm -Uvh Orchestration-1.1-1.noarch.rpm

#RUN chkconfig ntpd on



#RUN ntpd
#RUN named

#RUN su root -c hostname foo.bar.baz
#RUN echo "NETWORKING=yes" > /etc/sysconfig/network
#RUN echo "HOSTNAME=foo.bar.baz" >> /etc/sysconfig/network
CMD ./run.sh && bash #tail -F /usr/share/glassfish3/glassfish/domains/domain1/logs/server.log

#CMD ["/sbin/service", "ntpd", "start", "&&", "bash"]

#RUN echo service named start >> /etc/rc.local
#RUN echo service ntpd start >> /etc/rc.local
#CMD ["/etc/rc.local"]
#RUN chown root:root /etc/rc.local

#docker build -t coretest .
#docker run -it coretest bash
