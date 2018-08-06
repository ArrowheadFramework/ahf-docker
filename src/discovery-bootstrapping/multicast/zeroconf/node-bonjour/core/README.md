# node-bonjour server

Server-side of the NodeJS implementation of service discovery bootstrapping through 
zeroconf/Bonjour.

## Usage
```bash
docker build -t node-bonjour-server .
docker run \
        --rm \
        --network host \
        --env SERVICE_TYPE="http" \
        --env SERVICE_PORT=8080 \
        --env SERVICE_PATH="/simpleservicediscovery" \
        --env PUBLISH_HOST="glassfish.docker.ahf" \
        node-bonjour-server
```

## Environment variables
### SERVICE_NAME
Represents the type of name of the service we will be publishing. This must be
unique.

**Default**: `sd1`

### SERVICE_TYPE
Represents the type of service that we are publishing. Generally it will be one of
`http`, `https` or `coap`, but others might be used. Most likely, the client will use 
it as the _scheme_ part of a URI, so keep this in mind. It is, however, still the 
responsibility of the client to handle this correctly.

**No default**. The container will print an error and exit if no value is given.

### SERVICE_PORT
Represents the port of the service to be published.

**No default**. The container will print an error and exit if no value is given.

### SERVICE_PATH
Represents the relative path of the service to be published. It refers in the URI to
the path section, where a URI is formed as follows:

```text
scheme:[//[user[:password]@]host[:port]][/path][?query][#fragment]
```

**No default**. The container will print an error and exit if no value is given.

### PUBLISH_HOST
The host for the service to be published.

**No default**. The value of `NETWORK_INTERFACE` will be used to get the container's IP
if none is given. If neither variable has a value, the container will print an error
and exit.

### PUBLISH_IP
The IP address for the service to be published.

**No default**. The value of `NETWORK_INTERFACE` will be used to get the container's IP
if none is given. If neither variable has a value, the container will print an error
and exit.

### NETWORK_INTERFACE
The network interface from which to pull the current IP to be published if none is 
given in `PUBLISH_ADDR`.

**Default**: `eth0`. This is the default interface for containers in Docker.

Please note that if the container's IP is published, the IP address will only work 
in single-host environments unless a network driver other than the default (`bridge`),
such as `host` or `macvlan` is used.

* When using `host`, ensure that the `NETWORK_INTERFACE` value given is the name of
an interface found on the actual host (e.g. as obtained from `ip address`). 
* When using `macvlan`, consider that the IP address given using `--ip` when running
the container is the one that will be published. Unless that somehow is the same that
can be used to connect to the actual service (Service Registry), you should use
`PUBLISH_ADDR`.

## Using Macvlan
In case you prefer not to use `--network host`, you may use a macvlan network driver
which should allow you to perform multicast from Docker if your engine supports it.

The network interface information should be acquired by using your operating system's 
tools (e.g. `ip address`)

* Remove the network if you have done this before and want to reconfigure, otherwise
skip.
```bash
docker network rm mcast_net
```

* Create the network (get the information from your OS). The name of the network is
`mcast_net`, you may change that to anything you prefer.
```bash
docker network create -d macvlan \
            -o parent=eth0 \
            --subnet=192.168.0.0/24 \
            --gateway=192.168.0.1 \
            mcast_net
```

* Re-build the container if necessary (note that the build step is independent of the
network you will use when running it).
```bash
docker build -t node-bonjour-server .   
```

* Run the container selecting the created network and an IP which falls under the 
correct network segment (e.g. your current IP + 10).
```bash
IP_ADDRESS=$(ip route get 1 | awk '{print $NF;exit}')
docker run \
        --rm \
        --network mcast_net \
        --ip 192.168.0.121 \
        --env SERVICE_TYPE="http" \
        --env SERVICE_PORT=8080 \
        --env SERVICE_PATH="/simpleservicediscovery" \
        --env PUBLISH_HOST="glassfish.docker.ahf" \
        --env PUBLISH_IP="$IP_ADDRESS" \
        node-bonjour-server
```

Above we get our public IP address and configure our container to publish that instead 
of the one we gave it using macvlan.