# ws-discovery-client

Client-side of the Python implementation of service discovery bootstrapping through 
WS-Discovery.

## Usage:
```bash
docker build -t ws-discovery-client .
docker run \
       --rm \
       --network host \
       --env TIMEOUT="2.0" \
       --name ws-discovery-client \
       ws-discovery-client
```

## Environment variables
### TIMEOUT
Time to be spent, in seconds, searching for the given service. Accepts floats.

**Default**: `2.0` (two seconds).

Please note that the container will run longer than the given timeout even when given
very low values as there is overhead in starting and stopping, particularly on slow 
hardware.

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
docker build -t ws-discovery-client .   
```

* Run the container selecting the created network and an IP which falls under the 
correct network segment (e.g. your current IP + 10).
```bash
docker run \
       --rm \
       --network mcast_net \
       --ip 192.168.0.120 \
       --env TIMEOUT="1.0" \
       --name ws-discovery-client \
       ws-discovery-client
```
