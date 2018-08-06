# socat-bootstrap-client

Client-side of the socat-based Arrowhead service discovery bootstrapper.

It will send multicast message to a given group on a given UDP port. The server-side
is expected to respond, regardless of the message, with the URI or host of the
Service Registry.

## Usage:
```bash
docker build -t socat-bootstrap-client .
docker run \
       --rm \
       --network host \
       --name socat-bootstrap-client \
       --env OUTPUT_FILENAME="bootstrap" \
       socat-bootstrap-client
```

## Environment variables
### MCAST_GROUP
Multicast group to join, on which bootstrapping messages are expected.

**Default**: `224.1.0.1`.

### MCAST_PORT
Multicast group to join, on which bootstrapping messages are expected.

**Default**: `6666`.

### OUTPUT_FILENAME
Name of the file where results should be stored. If no value is given, results will
not be stored, only printed. The file will be available in the /out/ directory, which
can be be used by other containers through a volume.

**No default**.


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
docker build -t socat-bootstrap-client .
```

* Run the container selecting the created network and an IP which falls under the
correct network segment (e.g. your current IP + 10).
```bash
docker run \
       --rm \
       --network mcast_net \
       --ip 192.168.0.120 \
       --name socat-bootstrap-client \
       --env OUTPUT_FILENAME="bootstrap" \
       socat-bootstrap-client
```
