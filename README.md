# ahf-docker

_*Disclaimer:* This is work under progress. Please submit any issues you find._

## Overview

This repository contains Docker containers for the Arrowhead project (subject to its corresponding license).
These containers allow for quicker development without the need for connecting to an existing _local cloud_.
Currently, these containers are at an alpha stage. Please submit any issues you find or enhancements you
would like to see.

## Usage

To start using it:
* Install `docker` and `docker-compose`
* Clone the repository
* Run `docker-compose up` from the *core* directory.
  * To apply any changes to the docker files, you will have to do `docker-compose buld` first (even if you are 
  working from a different copy of the project, because the previous build is cached and docker-compose currently
  does not look for changes automatically).
* *(Windows)* Docker might your credentials to share your drive. This is necessary to output the TSIG file to the host.
You may remove this behaviour by editing the `docker-compose.yml` file and removing any `volumes` entries and their
children.

To use it with a new project, particularly if you are using the core-utils library, you will need to provide the
JVM with the following parameters:

```
-Ddns.server=<IP_of_the_docker_interface>
-Ddnssd.hostname=<ip_or_name_holding_your_service>
-Ddnssd.domain=srv.docker.ahf.
-Ddnssd.browsingDomains=srv.docker.ahf.
-Ddnssd.registerDomain=srv.docker.ahf.
-Ddnssd.tsig="<tsig_file_location>"
```
If you are using an older version of core-utils, the JVM parameters might be different:

```
-Ddns.server=<IP_of_the_docker_interface>
-Ddnssd.hostname=<ip_or_name_holding_your_service>
-Ddnssd.domain=docker.ahf.
-Ddnssd.browsingDomains=docker.ahf.
-Ddns.registerDomain=docker.ahf.
-Ddnssd.tsig="<tsig_file_location>"
```

### Connection and security

To connect to services running in your own computer you may use the `127.0.0.1` local IP along with the corresponding service
port. Docker sets up the necessary bindings for the corresponding containers.

If you wish to connect to the services from external machines, you may use the host's IP address. If there are any issues, you
should check your firewall and, in Linux, the setting of `net.ipv4.conf.all.forwarding`.

You may also use that system parameter if you wish to restrict services to only be accesible by the host running the containers.
To do this, you would run the following command (which you can change at any point during runtime without having to restart the
containers):

```
$ sudo sysctl net.ipv4.conf.all.forwarding=0
```

Alternatively, you may set up rules in your firewall, but that is beyond the scope of this document.

### TSIG

The TSIG file is used by the DNS server to autheticate update requests. It is made available after starting the 
container for easy usage with core-utils. It can be located in `./out/tsig`. If you need to modify it for any 
reasons, it should maintain the following format used by core-utils at least up to version 1.7.

```
key.docker.ahf.
<key>
```

*The TSIG key usage can currently be bypassed. This is an alpha release. Please do not use if security is a
concern. _(If necessary, though, TSIG usage can be easily enforced by editing the named.conf.template file)_*


## SimpleServiceDiscovery

Systems without DNS-SD capabilities might consider using the SimpleServiceDiscovery service which is included.
[Developed by Federico Montori and Hasan Derhamy](https://bitbucket.org/fedeselmer/simpleservicediscovery/), this service provides a REST API for performing operations on the service registry.

The docker compose configuration will automatically deploy it. The corresponding files are located in the 
`simpleservicediscovery` directory.

To test it, you may perform a simple query as follows:
```
curl 127.0.0.1:8045/servicediscovery/service
```

The rest of the API will be documented here soon. For the time being please refer to the repository linked above.


## Testing

Correct deployment of the different components can be quickly tested as follows. These commands assume you are currently
at the `core` folder.

### Service Discovery
This is only an EJB used by Orchestration and Authorisation, so there is no direct way to test it. You can, however check
that it is deployed by using the following command. You will be asked to accept the server's certificate and to log in as
the Glassfish administrator (default is admin:pass).
```
docker exec -it core_glassfish_1 /glassfish3/glassfish/bin/asadmin list-applications
```

### Orchestration
```
curl https://127.0.0.1:8181/orchestration/store/orchestration/configurations -k --cert tls/cert.pem:changeit -i
```

### Authorisation
This one is actually not working at the moment:
```
curl https://127.0.0.1:8181/authorisation/authorisation -k -i -X POST -H 'Content-Type: application/xml' -d '<AuthorisationRequest><serviceType></serviceType><serviceName></serviceName><distinguishedName></distinguishedName></AuthorisationRequest>' --cert tls/cert.pem:changeit
```

### Management Tool
In your explorer you may use this tool. Head to [127.0.0.1:8080/managementtool] and input the Glassfish administrator
credentials (default are admin:pass).


## Disclaimer

*This might open ports in your computer. Please refer to the [Connection and security](https://github.com/ArrowheadFramework/ahf-docker#connection-and-security) section *
