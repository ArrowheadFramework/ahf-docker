# Docker: Arrowhead Core 3.2

This is a _dockerized_ version of the Arrowhead Framework V3.2 core services
combined API.

Please note that this is a potentially un-documented part of the version 3.2
release and therefore might become unavailable later on. At present it is useful
for running all of the core services from one container. It also includes a
number of operations not accessible from any of the stand-alone services.

Some capabilities, such as automatically cleaning the Service Registry, are only
available on their respective stand-alone applications.

The core services contained here were implemented by AITIA International Inc.,
and the source code can be found [here](https://github.com/hegeduscs/arrowhead).

## Usage
This assumes you are already running the `arrowheadf/db:3.2` container or
another database configured for working with Arrowhead 3.2.
```bash
docker run --rm \
           --network ahf \
           --publish 8450:8450 \
           --publish 8451:8451 \
           --env DB_HOST=ahf-db \
           --name=ahf-core arrowheadf/core:3.2
```

## Tests
You can find the test commands under `doc/requests`. Soon they will be included
here as well.

## Helpful commands
If you need to register link a hostname with an IP locally, you can use the
hosts file. This is useful when testing TLS configurations. The instructions
below would let you, for example, get the IP of a container and assign it a host
name on your local machine.

Get the IP address of the container (where `ahf-api` is the name of the
container):
```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    ahf-api
```

Update or add a hosts entry with the container address:
```bash

# Configuration (modify as needed
sr_hostname="api.docker.ahf"
sr_container_name="ahf-api"

# Get current container address
sr_address=$(docker inspect -f \
    '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    "$sr_container_name")

# Comment out any previous entries for that host
sudo sed -Ei "s/(^[1-9].*$sr_hostname)/#\1/" /etc/hosts

# Add new host entry
echo "$sr_address $sr_hostname" | sudo tee -a /etc/hosts

# Verify
cat /etc/hosts

```

## Environment variables

* `$DB_HOST`
* `$DB_ADDRESS`
* `$KEYSTORE`
* `$KEYSTOREPASS`
* `$KEYPASS`
* `$TRUSTSTORE`
* `$TRUSTSTOREPASS`
* `$BASE_URI`
* `$BASE_URI_SECURED`
* `$DB_USER`
* `$DB_PASSWORD`
* `$DB_ADDRESS`
* `$LOG4J_ROOTLOGGER`
* `$LOG4J_APPENDER_DB`
* `$LOG4J_APPENDER_DB_DRIVER`
* `$LOG4J_APPENDER_DB_URL`
* `$LOG4J_APPENDER_DB_USER`
* `$LOG4J_APPENDER_DB_PASSWORD`
* `$LOG4J_APPENDER_DB_SQL`
* `$LOG4J_APPENDER_DB_LAYOUT`
* `$LOG4J_LOGGER_ORG_HIBERNATE`
