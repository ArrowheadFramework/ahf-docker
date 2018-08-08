# gatekeeper

This directory holds a container for running the Arrowhead Framework V3.2
core gatekeeper services.

The core services contained here were implemented by AITIA International Inc.,
and the source code can be found [here](https://github.com/hegeduscs/arrowhead).

## Instructions
### Running locally
Build this container by running the following command from this directory.

```bash
docker build --tag ahf-gatekeeper .
```

If you are running a container with a database prepared for Arrowhead 3.2, such
as the one located in `core/mysql/` and that container is connected to a Docker 
network named, for example, `ahf`. You can run this container as follows:

```bash
docker run --rm --network ahf --name ahf-gatekeeper ahf-gatekeeper
```

### Publish

### Un-publish

### Query 

## Helpful commands
Get the IP address of the container (where `ahf-gatekeeper` is the
name of the container):
```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    ahf-gatekeeper
```

Update or add a hosts entry with the container address:
```bash

# Configuration (modify as needed
sr_hostname="gatekeeper.docker.ahf"
sr_container_name="ahf-gatekeeper"

# Get current container address
sr_address=$(docker inspect -f \
    '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    "$sr_container_name")

# Comment out any previous entries for that host
sudo sed -Ei "s/(^[1-9].*$sr_hostname)/#\1/" /etc/hosts

# Add new host entry
[ -n "$sr_address" ] && echo "$sr_address $sr_hostname" | sudo tee -a /etc/hosts

# Verify
cat /etc/hosts

```

## Environment variables

### `$DB_ADDRESS`

### `$KEYSTORE`

### `$KEYSTOREPASS`

### `$KEYPASS`

### `$TRUSTSTORE`

### `$TRUSTSTOREPASS`

### `$BASE_URI`

### `$BASE_URI_SECURED`

### `$DB_USER`

### `$DB_PASSWORD`

### `$DB_ADDRESS`

### `$LOG4J_ROOTLOGGER`

### `$LOG4J_APPENDER_DB`

### `$LOG4J_APPENDER_DB_DRIVER`

### `$LOG4J_APPENDER_DB_URL`

### `$LOG4J_APPENDER_DB_USER`

### `$LOG4J_APPENDER_DB_PASSWORD`

### `$LOG4J_APPENDER_DB_SQL`

### `$LOG4J_APPENDER_DB_LAYOUT`

### `$LOG4J_LOGGER_ORG_HIBERNATE`
