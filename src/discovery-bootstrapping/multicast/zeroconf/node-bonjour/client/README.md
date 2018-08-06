# node-bonjour client

Client-side of the NodeJS implementation of service discovery bootstrapping through 
zeroconf/Bonjour.

## Usage:
```bash
docker build -t node-bonjour-client .
docker run --rm --network host node-bonjour-client
```

## Environment variables
### TIMEOUT
Time, in seconds, to be spent searching for the given service.

**Default**: `5` (five seconds).


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
            --env TIMEOUT="5" \
            mcast_net
```

* Re-build the container if necessary (note that the build step is independent of the
network you will use when running it).
```bash
docker build -t node-bonjour-client .   
```

* Run the container selecting the created network and an IP which falls under the 
correct network segment (e.g. your current IP + 10).
```bash
docker run \
       --rm \
       --network mcast_net \
       --ip 192.168.0.120 \
       --env TIMEOUT="5" \
       node-bonjour-client
```
