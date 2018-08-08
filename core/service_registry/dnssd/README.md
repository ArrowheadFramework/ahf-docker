# dnssd

This directory holds the containers necessary for running the DNS-SD version of
the Arrowhead Service Registry.

In this implementation by AITIA, service information is stored in DNS-SD format
in a `bind` server. For an implementation using relational databases, see
`jdbc`.

The Service Registry service is implemented as a stand-alone Java application
located in `service_jse/`, which can use any sufficiently compliant DNS-SD 
provider. A pre-configured server is given in `bind`. 
