# authorization

This directory holds a container for running the Arrowhead Framework V3.2
authorization control service core services.

The core services contained here were implemented by AITIA International Inc.,
and the source code can be found [here](https://github.com/hegeduscs/arrowhead).

## Instructions
### Running locally
Build this container by running the following command from this directory.

```bash
docker build --tag ahf-auth-control .
```

If you are running a container with a database prepared for Arrowhead 3.2, such
as the one located in `core/mysql/` and that container is connected to a Docker 
network named, for example, `ahf`. You can run this container as follows:

```bash
docker run --rm --network ahf --name ahf-auth-control ahf-auth-control
```

## Tests
These tests assume that the container is located at `auth.docker.ahf`. To have
your operating system recognize this hostname, you may modify your hosts file or 
use DNS resolution. See [Helpful commands](#Helpful-commands) for an example on
modifying the hosts file.

You can find the test commands under `doc/requests`. Soon they will be 
included here as well.

### Publish

### Un-publish

### Query 

## Helpful commands
Get the IP address of the container (where `ahf-auth-control` is the
name of the container):
```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    ahf-auth-control
```

Update or add a hosts entry with the container address:
```bash

# Configuration (modify as needed
sr_hostname="auth.docker.ahf"
sr_container_name="ahf-auth-control"

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

### `$ENABLE_AUTH_FOR_CLOUD`

### `$LOG4J_ROOTLOGGER`

### `$LOG4J_APPENDER_DB`

### `$LOG4J_APPENDER_DB_DRIVER`

### `$LOG4J_APPENDER_DB_URL`

### `$LOG4J_APPENDER_DB_USER`

### `$LOG4J_APPENDER_DB_PASSWORD`

### `$LOG4J_APPENDER_DB_SQL`

### `$LOG4J_APPENDER_DB_LAYOUT`

### `$LOG4J_LOGGER_ORG_HIBERNATE`