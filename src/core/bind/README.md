# Service Registry 3.0 container

This is a _dockerized_ version of `bind`, a name server (DNS), ready to be used
for the Arrowhead Framework 3.0.

## Usage

```bash
docker run --rm \
           --network ahf \
           --volume tsig:/tsig \
           --hostname bind.docker.ahf \
           --net-alias bind.docker.ahf \
           --env ALLOW_DOMAIN_UPDATE=true \
           --publish 53:53/udp \
           --name ahf-bind arrowheadf/serviceregistry:3.0
```

## Build from source

```bash
container_name=ahf-bind

curl -k -o "${container_name}".tar.gz \
'https://forge.soa4d.org/anonscm/gitweb?p=arrowhead-f/users/docker.git;a=snapshot;h=e2fe115958ab30717f366931d6fed031577d6c3c;sf=tgz'
mkdir -p "${container_name}"
tar -xvf "${container_name}".tar.gz -C "${container_name}" --strip-component=1

docker build -t "${container_name}" "${container_name}"
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
           --name "${container_name}" "${container_name}"
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
