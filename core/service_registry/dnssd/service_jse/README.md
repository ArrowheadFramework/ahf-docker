# service_jse

This directory holds a container for running the service registry for the 
Arrowhead Framework V3.2 core services. Specifically, it contains the version 
which uses DNS-SD (a pre-configured server can be found at `../bind`).

## Instructions
### Running locally
Build this container by running the following command from this directory.

```bash
docker build --tag ahf-sr-dnssd .
```

If you are running a container with a DNS-SD server prepared for Arrowhead 3.2,
such as the one located in `bind` and that container is connected to a Docker 
network named, for example, `ahf`. You can run this container as follows:

```bash
docker run --rm --network ahf --name ahf-sr-dnssd ahf-sr-dnssd
```

## Database
While this container may run without depending on any databases, one may be used
for logging.

Also, when starting the container, the current version attempts to load a
database which is not used. This results in an exception which has no effect
on the application, so you may ignore it or uncomment the corresponding 
`app.properties` entries pointing to any available JDBC connection.

## Tests
These tests assume that the service registry is located at `sr.docker.ahf`. To 
have your operating system recognize this hostname, you may modify your hosts 
file or use DNS resolution. See [Helpful commands](#Helpful-commands) for an 
example on modifying the hosts file.

### Publish

### Un-publish

### Query 

## Helpful commands
Get the IP address of the container (where `ahf-service-registry-mysql` is the
name of the container):
```bash
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
    ahf-sr-dnssd
```

Update or add a hosts entry with the container address:
```bash

# Configuration (modify as needed
sr_hostname="sr.docker.ahf"
sr_container_name="ahf-sr-dnssd"

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

### `$PING_TIMEOUT`

### `$PING_SCHEDULED`

### `$PING_INTERVAL`

### `$TSIG_NAME`

### `$TSIG_KEY`

### `$TSIG_ALGORITHM`

### `$DNS_IP`

### `$DNS_PORT`

### `$LOG4J_ROOTLOGGER`

### `$LOG4J_APPENDER_DB`

### `$LOG4J_APPENDER_DB_DRIVER`

### `$LOG4J_APPENDER_DB_URL`

### `$LOG4J_APPENDER_DB_USER`

### `$LOG4J_APPENDER_DB_PASSWORD`

### `$LOG4J_APPENDER_DB_SQL`

### `$LOG4J_APPENDER_DB_LAYOUT`

### `$LOG4J_LOGGER_ORG_HIBERNATE`
