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

### Server IP

The IP of the docker interface can be found running `ifconfig` (or the corresponding command). In Linux, the
interface used by docker will be `br-*` whereas in Windows (unless you are using boot2docker), it will read
something along the lines of `DockerNAT`.

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

## Disclaimer

*This might open ports in your computer. Please consider this when using this alpha release.*
