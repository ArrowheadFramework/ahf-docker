#!/bin/sh
set -e

asadmin="$GLASSFISH_HOME/bin/asadmin"

# Add permissions for Java to listen on the database port
cat >> "${JAVA_POLICY_PATH}"  <<- EOM
grant {
     permission java.net.SocketPermission "localhost:1527", "listen,resolve";
 };
EOM

# The configuration needs the domain to be running
# And deployments need the database
${asadmin} start-domain
${asadmin} start-database

# Configure the given properties on the server
while read opt; do
  ${asadmin} set "${opt}";
done < ./glassfish.properties

# Set logging levels
${asadmin} set-log-levels javax.enterprise.system.container.ejb=SEVERE
${asadmin} set-log-levels javax.enterprise.system.container.web=SEVERE

# Deploy the applications (the ones which we can deploy on build-time without errors)
${asadmin} --interactive=false deploy ./service-registry.ear
${asadmin} --interactive=false deploy ./managementtool.war

# Clean up
${asadmin} stop-domain
rm ./service-registry.ear ./managementtool.war
