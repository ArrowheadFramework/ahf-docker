# ahf-docker

_*Disclaimer:* This is work in progress (WIP). Please submit
[here](https://forge.soa4d.org/tracker/?atid=304&group_id=58&func=browse) any
issues you find._

## Overview

This repository contains Docker containers for the Arrowhead project (subject to
its corresponding license). These containers allow for quicker development
without the need for connecting to an existing _local cloud_. Currently, these
containers are at an alpha stage. Please submit any issues you find or
enhancements you would like to see.

## Usage

### Requirements
Docker is required to run these containers. Installing Docker-Compose as well
will make it easier to get started quickly.

The following instructions use `docker-compose`, but if you prefer not to use
it, you can find the corresponding commands under **[Other useful
commands](#other-useful-commands)**. 

### Run
With GIT, Docker and Docker-Compose installed:
```bash
cd src/core
docker-compose up --build && docker-compose down -v
```

### Test 
```bash
cd src/soapui
docker-compose up --build && docker-compose down -v
```


**Note for Windows:** Docker might ask for your credentials to share your drive.
This is necessary to output the TSIG file to the host. You may remove this
behaviour by editing the `docker-compose.yml` file and removing any `volumes`
entries and their children.

## Connecting from a Java application

To make calls to the services from a Java application, and specifically, if you
are using the core-utils library, you will need to provide the JVM with the
following parameters:

```bash
-Ddns.server="<IP_of_the_docker_interface>"
-Ddnssd.hostname="<ip_or_name_holding_your_service>"
-Ddnssd.domain="srv.docker.ahf."
-Ddnssd.browsingDomains="srv.docker.ahf."
-Ddnssd.registerDomain="srv.docker.ahf."
-Ddnssd.tsig="<tsig_file_location>"
```

If you are using an older version of core-utils, the JVM parameters might be
different:

```bash
-Ddns.server="<IP_of_the_docker_interface>"
-Ddnssd.hostname="<ip_or_name_holding_your_service>"
-Ddnssd.domain="docker.ahf."
-Ddnssd.browsingDomains="docker.ahf."
-Ddns.registerDomain="docker.ahf."
-Ddnssd.tsig="<tsig_file_location>"
```

### Connection and security

To connect to services running in your own computer you may use the `127.0.0.1`
local IP along with the corresponding service port. Docker sets up the necessary
bindings for the corresponding containers.

If you wish to connect to the services from external machines, you may use the
host's IP address. If there are any issues, you should check your firewall and,
in Linux, the setting of `net.ipv4.conf.all.forwarding`.

You may also use that system parameter if you wish to restrict services to only
be accessible by the host running the containers. To do this, you would run the
following command (which you can change at any point during runtime without
having to restart the containers):

```bash
sudo sysctl net.ipv4.conf.all.forwarding=0
```

Alternatively, you may set up rules in your firewall, but that is beyond the
scope of this document.

#### Certificates, keys and TSIG
When the containers are run with `docker-compose` or with the suggested
parameters, they will create directories called `tls` and `tsig`. These contain
helpful files such as a CA certificate with its key, along with a signed testing
certificate, as well as a file with the TSIG key.To use these files outside of
docker, the proper permissions should be set. Docker does not have information
about your user so it cannot give you permissions.

To help you out in fast development, the containers will automatically set lax
permissions for these folders and their contents (777). THIS IS INSECURE and
will not be done unless you explicitly set the `LOCK_OUT_DIR` environment
variable to false.

To help out anyone who wants to get things up and running quickly, this
`LOCK_OUT_DIR` is set to false in the core docker-compose file. Modify it as
needed.

### TSIG

The TSIG file is used by the DNS server to autheticate update requests. It is
made available after starting the container for easy usage with core-utils. It
can be located in `./out/tsig`. If you need to modify it for any reasons, it
should maintain the following format used by core-utils at least up to version
1.7.

```
key.docker.ahf.
<key>
```

*The TSIG key usage can currently be bypassed. This is an alpha release. Please
do not use if security is a concern. _(If necessary, though, TSIG usage can be
easily enforced by editing the named.conf.template file)_*


## SimpleServiceDiscovery

Systems without DNS-SD capabilities might consider using the
SimpleServiceDiscovery service included here. [Developed by Federico Montori and
Hasan Derhamy](https://bitbucket.org/fedeselmer/simpleservicediscovery/), this
service provides a REST API for performing operations on the service registry.

The docker compose configuration will automatically deploy it. The corresponding
files are located in the `simpleservicediscovery` directory.

To test it, you may perform a simple query as follows:

```bash
curl 127.0.0.1:8045/servicediscovery/service
```

The rest of the API will be documented here soon. For the time being please
refer to the repository linked above.


## Testing

Correct deployment of the different components can be quickly tested as follows.
These commands assume you are currently at the `core` folder.

### Service Discovery
This is only an EJB used by Orchestration and Authorisation, so there is no
direct way to test it. You can, however check that it is deployed by using the
following command. You will be asked to accept the server's certificate and to
log in as the Glassfish administrator (default is admin:pass).

```bash
docker exec -it \
    core_glassfish_1 /glassfish3/glassfish/bin/asadmin list-applications
```

It might ask for user and pass, if you activated the secure Glassfish option.
The values are those you provided for Glassfish administration (default:
**admin**, **pass**).

### Orchestration
```bash
curl https://127.0.0.1:8181/orchestration/store/orchestration/configurations \
    -k --cert tls/cert.pem:changeit -i
```

### Authorisation
This one is actually not working at the moment:

```bash
curl https://127.0.0.1:8181/authorisation/authorisation \
    -k -i -X POST -H 'Content-Type: application/xml' \
    -d '<AuthorisationRequest><serviceType/><serviceName/><distinguishedName/></AuthorisationRequest>' \
    --cert tls/cert.pem:changeit
```

### Management Tool
In your explorer you may use this tool. Head to
`http://127.0.0.1:8080/managementtool` and input the Glassfish administrator
credentials (default are admin:pass).


## Other useful commands

* To start an instance of the DNS server (`bind`) without docker-compose.
```bash
docker build -t ahf-bind src/core/bind
docker network create ahf
docker run --rm \
           --network ahf \
           --volume tsig:/tsig \
           --hostname bind.docker.ahf \
           --net-alias bind.docker.ahf \
           --env ALLOW_DOMAIN_UPDATE=true \
           --env SERVER_DOMAIN=docker.ahf \
           --env SERVER_HOSTNAME=bind.docker.ahf \
           --publish 53:53/udp \
           --name ahf-bind ahf-bind
```

* To start an instance of the application server (`glassfish`) without
docker-compose.
```bash
docker build -t ahf-glassfish src/core/glassfish
docker network create ahf
docker run --rm \
           --network ahf \
           --volume tls:/tls \
           --volume tsig:/tsig \
           --hostname glassfish.docker.ahf \
           --net-alias glassfish.docker.ahf \
           --net-alias docker \
           --env LOCK_OUT_DIR=false \
           --env GLASSFISH_ADMIN=admin \
           --env GLASSFISH_PASSWORD=password \
           --env KEYSTORE_PASSWORD=changeit \
           --env TESTER_KEYSTORE_PASSWORD=changeit \
           --env DNS_SERVER=bind.docker.ahf \
           --env SECURE_GLASSFISH=true \
           --env SERVER_HOSTNAME=glassfish.docker.ahf \
           --env SERVER_DOMAIN=docker.ahf \
           --env REGISTER_WITH_DNS=true \
           --env DO_DYNAMIC_DNS_UPDATE=true \
           --publish 8080:8080 \
           --publish 8181:8181 \
           --name=ahf-glassfish ahf-glassfish
```

* To start an instance of the service registry proxy (`simpleservicediscovery`)
without docker-compose.
```bash
docker build -t ahf-ssd src/core/simpleservicediscovery
docker network create ahf
docker run --rm \
           --network ahf \
           --volume tls:/tls \
           --volume tsig:/tsig \
           --hostname simpleservicediscovery.docker.ahf \
           --env DNS_SERVER=bind.docker.ahf \
           --env BROWSING_DOMAIN=docker.ahf \
           --env ORCHESTRATION_URL=https://glassfish.docker.ahf:8181/orchestration/store \
           --env AUTHORISATION_URL=https://glassfish.docker.ahf:8181/authorisation \
           --env WAIT_FOR_TLS_READY=true \
           --env WAIT_FOR_ORCH_STORE=true \
           --env SERVER_HOSTNAME=simpleservicediscovery.docker.ahf \
           --env SERVER_DOMAIN=docker.ahf \
           --env REGISTER_WITH_DNS=true \
           --env DO_DYNAMIC_DNS_UPDATE=true \
           --publish 8045:8045 \
           --name=ahf-ssd ahf-ssd
```

* To run the SoapUI test suite without docker-compose.
```bash
docker build -t ahf-soapui src/soapui
docker run --rm \
           --volume tls:/tls \
           --volume tsig:/tsig \
           --hostname soapui.docker.ahf \
           --network ahf \
           --name=ahf-soapui ahf-soapui
```

* To get the auto-generated TLS files, including the Certificate Authority
certificate and key. 

```bash
sudo cp -far "$(docker volume inspect tls | 
    grep Mountpoint | 
    sed -E 's/^\s*"\w*"\s*:\s*"(.*)".*$/\1/g')/." . && \
    sudo chown -R $USER:$USER .
```

* To get the auto-generated TSIG file.
```bash
sudo cp -far "$(docker volume inspect tsig | 
    grep Mountpoint | 
    sed -E 's/^\s*"\w*"\s*:\s*"(.*)".*$/\1/g')/." . && \
    sudo chown -R $USER:$USER .
```

* Clean up Docker:
```bash
docker system prune -a
```

* Completely clean up Docker (factory defaults / hard reset):
```bash
 sudo su -c "service docker stop &&
 rm -r /var/lib/docker/* &&
 service docker start"
```

## More information
You can find more information on the [Arrowhead Framework
Wiki](https://forge.soa4d.org/plugins/mediawiki/wiki/arrowhead-f/index.php/Local_cloud_deployment#Using_Docker_containers).

## Disclaimer

*This might open ports in your computer. Please refer to the [Connection and
security](#connection-and-security) section*
