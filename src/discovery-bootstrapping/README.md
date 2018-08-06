# Discovery Bootstrapping

This directory holds containers for bootstrapping service discovery.

When a new Arrowhead-enabled device is deployed on a network, there are a number
of ways to get it to connect to the core services. For instance, the simplest
option is to have these services located on a fixed location, which might be
good enough for some setups. An alternative is to use DNS; after all, the
Service Registry is currently based on DNS. While not ideal, practical scenarios
often require Arrowhead local clouds to be deployed on previously existing
networks, with extraneous devices and configurations; specifically, the network
might provide a given name server address which cannot be changed -- for
example, when a local cloud is deployed on a university campus where policy does
not allow configuring gateways to provide custom DNS resolution.

In these situations then, we need a way to locate core services located in the
network. This directory provides such solutions. These are, at the time being,
only proof of concept options which warrant further studying.

## Available options
 * Multicast             
   * Zeroconf(Bonjour/Avahi):  **_Available (1)_**
   * WS-Discovery:             **_Available (1)_**
   * Plain
     * socat:                  **_Available (1)_**
     * iperf:                  **_Pending_**
     * Hardware abstracted C:  **_Pending_**
   * COAP multicast:           **_Pending_**
 * Unicast search
   * Naive:                    **_Pending_**
   * Heuristical:              **_Pending_**
   * Naive with gossip:        **_Pending_**
   * Heuristical with gossip:  **_Pending_**
 * Fixed location
   * Last address of segment:  **_Pending_**
 * Orchestrator
   * Discover and configure:   **_Pending_**
   * Configure on deployment:  **_Pending_**
 * Physically-aided
   * USB configuration file:   **_Pending_**
   * D2D USB OTG:              **_Pending_**
   * NFC:                      **_Pending_**
   * BLE gossip:               **_Pending_**
   
## Usage
Regardless of the internal behaviour, each option should always have at least
one client application which, when successful, prints a list with potential
Service Registries, where each row contains two space-separated elements: the
URI of the service followed by the IP address for the host. For example:

```text
coap://serviceregistry.arrowhead.eu 192.168.0.1
http://serviceregistry.docker.ahf:8080/simpleserviceregistry 192.168.0.2
dns://192.168.0.3 192.168.0.3
```

This bootsrapping occurs under the assumption that name resolution might be
unavailable. On the other hand, Arrowhead often relies on TLS, where the host
name used to initiate the connection is compared against the name on the
received certificate. To satisfy this, both can be provided as shown above.

Some options require not only a client, but a server-side deployment which
either continually broadcasts its location or responds to discovery requests.
In these cases, the client side is to be located under `client` whereas the
server under `core`.

Options which depend on gossip or other peer mechanisms, require the
corresponding service on each peer. These, naturally, are to be located under
`peer`.

## Authentication, Authorisation, Access-Control
Please note that none of these solutions handle authentication, authorisation or
access control. This is purposefully so. Discovery and address resolution have
long been sources of security vulnerabilities (DNS and ARP poisoning, for
example). While I am open to discussing whether or not discovery can be secured:
intrinsically, by peer-rating or by other means, my current view is that
authentication should be done AFTER we have a potential service and assume that
anything we find is not what it appears until proven otherwise.

