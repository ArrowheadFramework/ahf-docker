# Arrowhead core 3.0 container

This is a _dockerized_ version of Glassfish, an application server for holding
the Arrowhead Framework 3.0 core services, pre-configured and with the necessary
applications loaded. to be used for the Arrowhead Framework 3.0.

## Usage
For this container to run, a name server is necessary. A dockerized one is
provided in the `arrowheadf/serviceregistry:3.0` container, this documentation
assumes you will use that and have already started it.

```bash
docker run --rm \
           --network ahf \
           --volume tls:/tls \
           --volume tsig:/tsig \
           --hostname glassfish.docker.ahf \
           --net-alias glassfish.docker.ahf \
           --env DNS_SERVER=bind.docker.ahf \
           --env REGISTER_WITH_DNS=true \
           --publish 8080:8080 \
           --publish 8181:8181 \
           --name=ahf-glassfish arrowheadf/core:3.0
```

## Build from source
```bash
container_name=ahf-glassfish

curl -k -o "${container_name}".tar.gz \
'https://forge.soa4d.org/anonscm/gitweb?p=arrowhead-f/users/docker.git;a=snapshot;h=d6f5675dee4b94dd666dbb026db3356cd1844573;sf=tgz'
mkdir -p "${container_name}"
tar -xvf "${container_name}".tar.gz -C "${container_name}" --strip-component=1

docker build -t "${container_name}" "${container_name}"
docker run --rm \
           --network ahf \
           --volume tls:/tls \
           --volume tsig:/tsig \
           --hostname glassfish.docker.ahf \
           --net-alias glassfish.docker.ahf \
           --net-alias docker \
           --env LOCK_OUT_DIR=false \
           --env GLASSFISH_ADMIN=admin \
           --env GLASSFISH_PASSWORD=pass \
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
           --name "${container_name}" "${container_name}"
```

## Environment Variables
Runtime of this container can be configured using the environment variables
below. They can be set when running the container by using the `--env` option.

All of them have reasonable default values, but some of the most important are
highlighted below, in case you need to modify them.


## Important
#### KEYSTORE_PASSWORD
Password for the auto-generated keystore available on the TLS volume.

Default is **changeit**.

#### TESTER_KEYSTORE_PASSWORD
Password for the auto-generated keystore available on the TLS volume containing
a certificate and key ready to be used for making HTTPS calls.

Default is **changeit**.

#### REGISTER_WITH_DNS
Automatically registers the container's IP address and hostname with the DNS
server. This is very useful for HTTPS calls.

For this to work it is required that the DNS server allows updates on the given
domain. To activate this functionality in the `bind` container, you only need to
set `ALLOW_DOMAIN_UPDATE=true`.

#### DO_DYNAMIC_DNS_UPDATE
If `REGISTER_WITH_DNS` is set to true, we can ensure our IP address is up to
date in the DNS server and update it when necessary. This is highly useful in
dynamic environments. Especially if we are using `network=host`.

#### IP_CHANGE_POLL_SECONDS
This allows us to control how often we will check our current IP address against
the address registered in the DNS server when `DO_DYNAMIC_DNS_UPDATE=true`.

Default is **5** seconds.

## Others
#### LISTENING_INTERFACE_NAME
#### SERVER_DOMAIN
#### SERVER_HOSTNAME
#### SERVER_ADDRESS
#### TESTER_KEYSTORE_PASSWORD
#### DNS_SERVER
#### SERVER_HOSTNAME
#### SERVER_DOMAIN
#### LOCK_OUT_DIR
#### SECURE_GLASSFISH
