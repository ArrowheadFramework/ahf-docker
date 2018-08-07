# SimpleServiceDiscovery 3.0 container

This is a _dockerized_ version of the HTTP proxy for the DNS-SD-based Arrowhead
service discovery. [Developed by Federico Montori and Hasan
Derhamy](https://bitbucket.org/fedeselmer/simpleservicediscovery/), this service
provides a REST API for performing operations on the service registry.

## Usage
For this container to run, a name server and the Arrowhead core services are
necessary. Readily dockerized versions of these can be found in
`arrowheadf/serviceregistry:3.0` and `arrowheadf/core:3.0`, correspondingly.

```bash
docker run --rm \
           --network ahf \
           --volume tls:/tls \
           --volume tsig:/tsig \
           --hostname simpleservicediscovery.docker.ahf \
           --env DNS_SERVER=bind.docker.ahf \
           --env ORCHESTRATION_URL=https://glassfish.docker.ahf:8181/orchestration/store \
           --env AUTHORISATION_URL=https://glassfish.docker.ahf:8181/authorisation \
           --publish 8045:8045 \
           --name=ahf-ssd arrowheadf/simpleservicediscovery:3.0
```

## Build from source
```bash
container_name=ahf-ssd

curl -k -o "${container_name}".tar.gz \
'https://forge.soa4d.org/anonscm/gitweb?p=arrowhead-f/users/docker.git;a=snapshot;h=0d04fe33f534849869c8450d9939041e29da9e4f;sf=tgz'
mkdir -p "${container_name}"
tar -xvf "${container_name}".tar.gz -C "${container_name}" --strip-component=1

docker build -t "${container_name}" "${container_name}"
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

#### WAIT_FOR_TLS_READY
Waits for the TLS certificates to be ready. You most likely want to use this, it
helps avoid race conditions.

Default is **true**.

#### WAIT_FOR_ORCH_STORE
Waits for the Orchestration store core service to respond. You most likely want
to use this, it helps avoid race conditions.

Default is **true**.

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
