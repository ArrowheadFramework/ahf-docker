# node-bonjour

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
docker build --tag node-bonjour-server core/
docker build --tag node-bonjour-client client/
```

[Optional] Disable packet forwarding.
```bash
sudo sysctl net.ipv4.conf.all.forwarding=0
```

Run the containers.
```bash
SERVER_ADDRESS=127.0.0.2
[ -n "SERVER_ADDRESS" ] && \
docker run \
       --rm \
       --network mcast_net \
       --ip 192.168.0.121 \
       --env SERVICE_NAME="sd1" \
       --env SERVICE_TYPE="http" \
       --env SERVICE_PORT=8080 \
       --env SERVICE_PATH="/simpleservicediscovery" \
       --env PUBLISH_HOST="glassfish.docker.ahf" \
       --env PUBLISH_IP="$SERVER_ADDRESS" \
       node-bonjour-server
docker run \
       --rm \
       --network mcast_net \
       --ip 192.168.0.122 \
       --env TIMEOUT="5" \
       node-bonjour-client
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
                    --tag node-bonjour-server core/
docker -H tcp://resin2.local:2375 build \
                    --tag node-bonjour-client client/
```

Run the containers.
```bash
SERVER_ADDRESS=$(ping resin1.local -c 1 | sed -n 1p | cut -d"(" -f2 | cut -d")" -f1)
[ -n "SERVER_ADDRESS" ] && \
docker -H "tcp://$SERVER_ADDRESS:2375" run \
                   --rm \
                   --network mcast_net \
                   --ip 192.168.0.121 \
                   --env SERVICE_NAME="sd1" \
                   --env SERVICE_TYPE="http" \
                   --env SERVICE_PORT=8080 \
                   --env SERVICE_PATH="/simpleservicediscovery" \
                   --env PUBLISH_HOST="glassfish.docker.ahf" \
                   --env PUBLISH_IP="$SERVER_ADDRESS" \
                   node-bonjour-server
docker -H tcp://resin2.local:2375 run \
                   --rm \
                   --network mcast_net \
                   --ip 192.168.0.122 \
                   --env TIMEOUT="5" \
                   node-bonjour-client
```

