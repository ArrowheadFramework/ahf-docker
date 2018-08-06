# socat-bootstrap-server

Server-side of the socat-based Arrowhead service discovery bootstrapper.

This bootstrapper opens a UDP socket on a given port listening for multicast messages
from a given group. It will respond to any messages from said group. The response will
be the URI of the service to be published (Service Registry).

In the scenario where not enough information is available to form a proper URI, at
least a host will be published. The value for the host would depend on the value of
`URI_HOST`.

## Usage
```bash
docker build -t ws-discovery-server .
docker run \
        --rm \
        --network host \
        --env URI_SCHEME="http" \
        --env URI_PORT=8080 \
        --env URI_PATH="/simpleservicediscovery" \
        --env PUBLISH_INTERFACE_NAME="eth0" \
        --env MCAST_INTERFACE="0.0.0.0" \
        --name socat-bootstrap-server \
        socat-bootstrap-server
```

## Environment variables
### Service information
#### URI related variables
These variables are used to determine the URI of the service to be published.
The URI related variables refer to the formal URI format as follows:

```text
scheme:[//[user[:password]@]host[:port]][/path][?query][#fragment]
```

If only the host part is available, it will be printed as is (not as a URI). This might
be changed in the future.

If `URI` is set, the following variables are ignored: `URI_SCHEME`, `URI_HOST`,
`URI_PORT`, `URI_PATH`, `PUBLISH_INTERFACE_NAME`.

##### URI
URI to be published. If set, the rest of the URI related variables are ignored.

If not set, it will be formed through the rest of the URI variables. If no URI related
variables are given, a best effort is made by using the IP address used for external
connections by the container (which depends on the container's network configuration).

* **No default**.
* **Optional**.

##### URI_SCHEME
Scheme part of the URI for the service to be published. For example: `https`, `coap`.

It is not used if `URI` is given.

* **No default**.
* **Optional**.

##### URI_HOST
Host part of the URI for the service to be published. For example: `192.168.0.110`.

It is not used if `URI` is given.

* **No default**.
* **Optional**.

##### URI_PORT
Port part of the URI for the service to be published. For example: `8181`.

It is not used if `URI` is given.

* **No default**.
* **Optional**.

##### URI_PATH
Path part of the URI for the service to be published. For example:
`/simpleservicediscovery`.

Please note that the path part of a URI is always prepended by a slash ('/'). When
assigning a value to this variable it is assumed you have included this.

It is not used if `URI` is given.

* **No default**.
* **Optional**.

##### PUBLISH_INTERFACE_NAME
If `URI_HOST` is unset, the IP address of the interface with the given name will be
used as the host part of the URI.

Example value: `eth0`

It is not used if `URI` or `URI_HOST` are given.

* **No default**.
* **Optional**.

### IP_ADDRESS
This variable is used to determine the IP address for the service to be
published. If the value is not given, the IP address of the interface by the
name `PUBLISH_INTERFACE_NAME` will be used. If both variables are empty, the
IP address used by the primary external route for the container would be used.

Example value: `127.0.0.1`

* **No default**.
* **Optional**.


### Multicast related variables
These variables describe the multicast configuration of the bootstrapper.

#### MCAST_INTERFACE
Determines the interface on which socat will listen for multicast messages.

* **Default**: `0.0.0.0` only if `MCAST_INTERFACE_NAME` is also unset.
* **Optional**.

#### MCAST_INTERFACE_NAME
If `MCAST_INTERFACE` is unset, the IP address of the interface with the given name will
be used for listening to multicast messages.

Example value: `eth0`

It is not used if `MCAST_INTERFACE` is given.

* **No default**.
* **Optional**.

#### MCAST_GROUP
Determines the group on which socat will listen for multicast messages.

* **Default**: `224.1.0.1`
* **Optional**.

#### MCAST_UDP_PORT
Determines the UDP port on which socat will listen for multicast messages.

* **Default**: `6666`
* **Optional**.


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
docker build -t socat-bootstrap-server .
```

* Run the container selecting the created network and an IP which falls under the
correct network segment (e.g. your current IP + 10).
```bash
IP_ADDRESS=$(ip route get 1 | awk '{print $NF;exit}')
docker run \
        --rm \
        --network mcast_net \
        --ip 192.168.0.121 \
        --env URI="http://glassfish.docker.ahf:8080/simpleservicediscovery" \
        --env IP_ADDRESS="${IP_ADDRESS}" \
        --env MCAST_INTERFACE="0.0.0.0" \
        --name socat-bootstrap-server \
        socat-bootstrap-server
```

Above we get our public IP address and configure our container to publish that instead
of the one we gave it using macvlan.
