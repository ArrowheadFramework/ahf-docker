# bind

This directory contains a _dockerized_ version of bind, a name server (DNS),
ready to be used for the Arrowhead Framework 3.0.

## Usage

```bash
docker build -t ahf-bind .
docker network create ahf
docker run --rm \
           --network ahf \
           --volume tsig:/tsig \
           --hostname bind.docker.ahf \
           --net-alias bind.docker.ahf \
           --env ALLOW_DOMAIN_UPDATE=true \
           --env SERVER_DOMAIN=docker.ahf \
           --env SERVER_HOSTNAME=bind.docker.ahf \
           --publish 53:53/udp \
           --name ahf-bind ahf-bind
```

## Environment Variables
Runtime of this container can be configured using the environment variables
below. They can be set when running the container by using the `--env` option.

All of them have reasonable default values, but some of the most important are
highlighted below, in case you need to modify them.

## Important
#### ALLOW_DOMAIN_UPDATE
Setting this to `true` will allow others to modify the DNS server entries. While
this is insecure in a production environment, it allows for easy
auto-registration of other containers in a development environment.

It is necessary to set this to `true` for the `DO_DYNAMIC_DNS_UPDATE` and
`REGISTER_WITH_DNS` capabilities from other containers to work. 

Defaults to **false**.

## Others
#### MEXSDOMAIN
#### SERVER_SHORT_HOSTNAME
#### SERVER_DOMAIN
#### SERVER_ADDRESS
#### SERVER_HOSTNAME
#### LISTENING_INTERFACE_NAME
#### LOCK_OUT_DIR
