# ahf-docker:4.0-lw

_*Disclaimer:* This is Work In Progress (WIP). Please raise any issues you 
find._

## Overview

This directory contains files for building a Docker image of the Arrowhead 
Framework 4.0 Core Services (lightweight version). 

## Usage

```bash
docker build -t ahf:4.0 .
```

You can test the image after building it by running the following command.

```bash
docker run -it --rm -p 8440:8440 --name ahf ahf:4.0
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