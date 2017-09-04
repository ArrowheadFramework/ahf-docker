#!/bin/bash
echo "Installing GlassFish server ..."

if test "`id -u`" -ne 0
	then 
	echo "You need to run this script as root!" 
	exit 1
fi

if [ -z "$BASH_VERSION" ]; then
  echo "Please do ./$0"
  exit 1
fi

ADMIN_PORT=4848
WEB_PORT=8080
SEC_WEB_PORT=8181

#wget http://download.oracle.com/glassfish/3.1.2.2/release/glassfish-3.1.2.2.zip
#unzip glassfish-3.1.2.2.zip
#rm -f glassfish-3.1.2.2.zip
rpm -Uvh jdk-7u25-linux-x64.rpm
rpm -Uvh glassfish-3.1.2.2-4.noarch.rpm

#echo "* Installing JDK"
#yum install -y jdk ||  { echo 'JDK Installation failed';exit 1; }
#echo "* Installation of JDK complete"
#echo "* Installing GlassFish"
#yum install -y glassfish ||  { echo 'GlassFish Installation failed';exit 1; }
#echo "* Installation of GlassFish complete"

GLASSFISH_HOME=/usr/share/glassfish3/glassfish/

echo "AS_ADMIN_PASSWORD=
AS_ADMIN_NEWPASSWORD=$GLASSFISH_PASSWORD" > chpwdfile
echo "AS_ADMIN_PASSWORD=$GLASSFISH_PASSWORD" > pwdfile
echo "Glassfish password is $GLASSFISH_PASSWORD"
echo "* Installing certificates"
$GLASSFISH_HOME/bin/asadmin stop-domain domain1
$GLASSFISH_HOME/bin/asadmin delete-domain domain1
$GLASSFISH_HOME/bin/asadmin create-domain --keytooloptions CN=$DOCKER_HOSTNAME --nopassword=true --user=glassfishAdmin domain1

echo "* Change GlassFish admin password"
$GLASSFISH_HOME/bin/asadmin --user glassfishAdmin --passwordfile=./chpwdfile change-admin-password #||  { echo 'Password not set correctly!';exit 1; }
#rm chpwdfile
#exit
#/sbin/service glassfish start || { echo 'GlassFish service NOT started';exit 1; }
$GLASSFISH_HOME/bin/asadmin start-domain

#echo "* Now login once for the rest of the session *"
#$GLASSFISH_HOME/bin/asadmin --user glassfishAdmin --passwordfile=./pwdfile --host localhost --port 4848 login

GLASSFISH_ASADMIN="$GLASSFISH_HOME/bin/asadmin --user glassfishAdmin --passwordfile=./pwdfile"

echo "* Enable client certificates *"
$GLASSFISH_ASADMIN delete-auth-realm certificate
$GLASSFISH_ASADMIN create-auth-realm --classname com.sun.enterprise.security.auth.realm.certificate.CertificateRealm --property assign-groups=peer certificate
$GLASSFISH_ASADMIN delete-ssl --type http-listener http-listener-2
$GLASSFISH_ASADMIN create-ssl --certname s1as --type http-listener --ssl3enabled=true --tlsenabled=true --clientauthenabled=true http-listener-2

echo "* Configuring EJB Timer Service *"
$GLASSFISH_ASADMIN set server-config.ejb-container.ejb-timer-service.property.reschedule-failed-timer=true

echo "* Increasing http max-thread-pool-size *"
$GLASSFISH_ASADMIN set server.thread-pools.thread-pool.http-thread-pool.max-thread-pool-size=50

echo "* Disabling socket read timeout *"
$GLASSFISH_ASADMIN set server-config.network-config.protocols.protocol.http-listener-1.http.request-timeout-seconds=-1
$GLASSFISH_ASADMIN set server-config.network-config.protocols.protocol.http-listener-2.http.request-timeout-seconds=-1

$GLASSFISH_ASADMIN create-jvm-options '-Ddnssd.registerDomain=docker.ahf.'

echo "* Enabling secure admin interface"
$GLASSFISH_ASADMIN --host localhost --port $ADMIN_PORT enable-secure-admin
/sbin/service glassfish restart || { echo 'GlassFish service NOT started';exit 1; }

echo "asadmin://glassfishAdmin@localhost:4848 $GLASSFISH_PASSWORD_BASE64" > /root/.asadminpass
$GLASSFISH_HOME/bin/asadmin start-database
$GLASSFISH_HOME/bin/asadmin restart-domain

rpm -Uvh ServiceRegistry-1.1.2-1.noarch.rpm
#echo "Clearing server log."
#echo "It will only contain info on Authorisation and Orchestration deployments."
#echo "" > `find / | grep server.log`
rpm -Uvh Authorisation-1.2-1.noarch.rpm
rpm -Uvh Orchestration-1.1-1.noarch.rpm

#echo ""
#echo ""
#echo ""
#echo "---------------------"
#echo "SERVER LOG BEGINS"
#echo "---------------------"
#cat `find / | grep server.log`
#echo "---------------------"
#echo "SERVER LOG ENDS"
#echo "---------------------"

####
# Firewall should be configured on the host machine, not the container.
####

## Firewall rules
#if ! iptables -L -n | grep "tcp dpt:$ADMIN_PORT" > /dev/null ; then
#  iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport $ADMIN_PORT -j ACCEPT
#fi
#
#if ! iptables -L -n | grep "tcp dpt:$WEB_PORT" > /dev/null ; then
#  iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport $WEB_PORT -j ACCEPT
#fi
#
#if ! iptables -L -n | grep "tcp dpt:$SEC_WEB_PORT" > /dev/null ; then
#  iptables -I INPUT -p tcp -m state --state NEW -m tcp --dport $SEC_WEB_PORT -j ACCEPT
#fi
#
#
#/sbin/service iptables save
#/sbin/service iptables restart
