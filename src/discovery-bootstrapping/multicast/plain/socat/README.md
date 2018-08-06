# socat

This directory contains an application of `socat` for bootstrapping Arrowhead service
discovery.


# Usage
## Two local containers

[Optional] Remove the Docker networks.
```bash
docker network rm mcast_net
```

[Optional] Create the networks.
```bash
docker network create \
            -d macvlan \
            --subnet=192.168.0.0/24 \
            --gateway=192.168.0.1 \
            -o parent=wlp58s0 \
            mcast_net
```

Build the images.
```bash
docker build --tag socat-bootstrap-server core/
docker build --tag socat-bootstrap-client client/
```

[Optional] Disable packet forwarding.
```bash
sudo sysctl net.ipv4.conf.all.forwarding=0
```

Run the containers.
```bash
SERVER_ADDRESS=127.0.1.1
[ -n "SERVER_ADDRESS" ] && \
docker run \
       --rm \
       --network mcast_net \
       --ip 192.168.0.121 \
       --env URI="http://glassfish.docker.ahf:8080/simpleservicediscovery" \
       --env IP_ADDRESS="${SERVER_ADDRESS}" \
       --env MCAST_INTERFACE="192.168.0.121" \
       --name socat-bootstrap-server \
       socat-bootstrap-server
docker run \
       --rm \
       --network mcast_net \
       --ip 192.168.0.122 \
       --name socat-bootstrap-client \
       --env OUTPUT_FILENAME="bootstrap" \
       --volume bootstrapping:/out \
       socat-bootstrap-client
```

## Publish the DNS address for core docker-compose
```bash
SERVER_ADDRESS=$(docker inspect -f "{{ .NetworkSettings.Networks.core_ahf.IPAddress }}" core_bind_1)
[ -n "SERVER_ADDRESS" ] && \
docker run \
       --rm \
       --network mcast_net \
       --ip 192.168.0.121 \
       --env URI_SCHEME="dns" \
       --env URI_HOST="${SERVER_ADDRESS}" \
       --env IP_ADDRESS="${SERVER_ADDRESS}" \
       --env MCAST_INTERFACE="192.168.0.121" \
       --name socat-bootstrap-server \
       socat-bootstrap-server
```

[Optional] Re-enable packet forwarding.
```bash
sudo sysctl net.ipv4.conf.all.forwarding=1
```


## Two resin devices
[Optional] Remove the Docker networks.
```bash
docker -H tcp://resin1.local:2375 network rm mcast_net
docker -H tcp://resin2.local:2375 network rm mcast_net
```

[Optional] Create the networks.
```bash
docker -H tcp://resin1.local:2375 network create \
                         -d macvlan \
                         --subnet=192.168.0.0/24 \
                         --gateway=192.168.0.1 \
                         -o parent=eth0 \
                         mcast_net
docker -H tcp://resin2.local:2375 network create \
                         -d macvlan \
                         --subnet=192.168.0.0/24 \
                         --gateway=192.168.0.1 \
                         -o parent=eth0 \
                         mcast_net
```

Build the images.
```bash
docker -H tcp://resin1.local:2375 build \
                    --tag socat-bootstrap-server core/
docker -H tcp://resin2.local:2375 build \
                    --tag socat-bootstrap-client client/
```

Run the containers.
```bash
SERVER_ADDRESS=$(ping resin1.local -c 1 | sed -n 1p | cut -d"(" -f2 | cut -d")" -f1)
[ -n "SERVER_ADDRESS" ] && \
docker -H tcp://resin1.local:2375 run \
           --rm \
           --network mcast_net \
           --ip 192.168.0.121 \
           --env URI="http://glassfish.docker.ahf:8080/simpleservicediscovery" \
           --env IP_ADDRESS="${SERVER_ADDRESS}" \
           --env MCAST_INTERFACE="0.0.0.0" \
           --name socat-bootstrap-server \
           socat-bootstrap-server
docker -H tcp://resin2.local:2375 run \
           --rm \
           --network mcast_net \
           --ip 192.168.0.122 \
           --name socat-bootstrap-client \
           --env OUTPUT_FILENAME="bootstrap" \
           --volume bootstrapping:/out \
           socat-bootstrap-client
```

## Third-party licensing
Full licenses under `LICENSES-3rd`.
