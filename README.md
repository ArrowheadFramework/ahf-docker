# ahf-docker:4.0-lw

_*Disclaimer:* This is Work In Progress (WIP). Please raise any issues you 
find._

## Overview

This directory contains Docker containers for the Arrowhead project (subject to
its corresponding license). These containers allow for quicker development
without the need for connecting to an existing _local cloud_. Currently, these
containers are at an alpha stage. Please submit any issues you find or
enhancements you would like to see.

This document and the contents of this directory are for version *4.0-lw* of the
Arrowhead Framework. If you are interested in a different version, please see
the corresponding directory.

Version 4.0-lw is a lightweight implementation which contains all core services
in a single Java JAR file. In turn, this container wraps everything necessary
for running the Arrowhead 4.0 core services, including a pre-configured MySQL
database. This is ideal for demonstrations, PoCs and projects with other tight
requirements which might not allow several containers to be run.

## Usage

To run the core container, you would first build it and then run it.

```bash
docker build -t ahf:4.0 src/core
```

```bash
docker run -it --rm -p 8440:8440 --name ahf ahf:4.0
```

## API documentation
Documentation for the API has been auto-generated and is provided in the `doc`
directory.

You can find a [Swagger](https://swagger.io/) file called `arrowhead-core.json`
which can be imported into SoapUI, Postman and other tools to generate client
source code for different languages. For more information refer to
`src/tools/generate-swagger/doc`.

A modified version of this file has been [published on
SwaggerHub](https://app.swaggerhub.com/apis/arrowhead-f/arrowhead-4_0_core/4.0).

Apart from this file, you can find `api.html`, which contains a simple page
listing all the available endpoints. For most of these, the auto-generator was
capable of including body examples (payloads) where necessary.

## Other useful commands

* To get the data from a volume called `tls`.
```bash
sudo cp -far "$(docker volume inspect tls | 
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

## Environment Variables
Any of the properties accepted by the Arrowhead Core 4.0 Lightweight application
can be overridden by using an environment variable of the same name (but in
uppercase and substituting dots by underscores).

For example, to set the property `ttl_interval`, we would use the environment
variable `TTL_INTERVAL` as follows

```bash
docker run -it --rm -p 8440:8440 -e TTL_INTERVAL=1000 --name ahf ahf:4.0
```

The available variables are as follows. For the purpose of each, contact the
Arrowhead Core 4.0 developers.

### SERVER_ADDRESS
### GATEWAY_ADDRESS
### DB_USER
### DB_PASSWORD
### DB_ADDRESS
### CLOUD_KEYSTORE
### CLOUD_KEYSTORE_PASS
### CLOUD_KEYPASS
### AUTH_KEYSTORE
### AUTH_KEYSTOREPASS
### EVENT_PUBLISHING_DELAY
### REMOVE_OLD_FILTERS
### FILTER_CHECK_INTERVAL
### GATEWAY_SOCKET_TIMEOUT
### USE_GATEWAY
### MASTER_ARROWHEAD_CERT
### MIN_PORT
### MAX_PORT
### GATEWAY_KEYSTORE
### GATEWAY_KEYSTORE_PASS
### PING_SCHEDULED
### PING_TIMEOUT
### PING_INTERVAL
### TTL_SCHEDULED
### TTL_INTERVAL
### LOG4J_ROOTLOGGER
### LOG4J_APPENDER_DB
### LOG4J_APPENDER_DB_DRIVER
### LOG4J_APPENDER_DB_URL
### LOG4J_APPENDER_DB_USER
### LOG4J_APPENDER_DB_PASSWORD
### LOG4J_APPENDER_DB_SQL
### LOG4J_APPENDER_DB_LAYOUT
### LOG4J_LOGGER_ORG_HIBERNATE

## Disclaimer

Some of the instructions in this document will open ports on your computer 
depending on your configuration. This is expected. If you are concerned about 
the security implications, you may isolate your computer through different 
means, some of them are discussed in the corresponding sections. To further 
understand the different means of isolating your computer, please refer to 
the documentation of your operating system and Docker.

_It is the responsibility of the user to ensure security of their system. The 
authors of any tool contained or described here are not liable for any 
damages resulting from usage of these tools._
