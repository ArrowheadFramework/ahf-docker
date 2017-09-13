# ahf-docker

_*Disclaimer:* This is work under progress. The instructions will be heavily updated in the following days.
The same goes for the actual containers, please submit any issues you find._

This repository contains Docker containers for the Arrowhead project (subject to its corresponding license).
To start using it install `docker` and `docker-compose`, clone the repository and run `docker-compose up` from
the *core* directory.

To use it with a new project, particularly if you are using the core-utils library, you will need to provide the
JVM with the following parameters:

```
-Ddns.server=<IP_of_the_dns_container>
-Ddnssd.hostname=<ip_or_name_holding_your_service>
-Ddnssd.domain=srv.docker.ahf.
-Ddnssd.browsingDomains=srv.docker.ahf.
-Ddnssd.registerDomain=srv.docker.ahf.
-Ddnssd.tsig="<tsig_file_location>"
```
If you are using an older version of core-utils, the JVM parameters might be different:

```
-Ddns.server=<IP_of_the_dns_container>
-Ddnssd.hostname=<ip_or_name_holding_your_service>
-Ddnssd.domain=docker.ahf.
-Ddnssd.browsingDomains=docker.ahf.
-Ddns.registerDomain=docker.ahf.
-Ddnssd.tsig="<tsig_file_location>"
```

The IP of the DNS container can be found through the `docker network ls` and `docker network inspect` commands.
Alternatively, you may run `ifconfig` (or the corresponding command) and use the IP address of the br-* adapter.

As for the tsig file. It is a two line file with the key name followed by the TSIG key in the next line.
Currently the TSIG key is printed very early in the printed log, this will be updated to allow for retrieving it
more easily. For the time being you may use *CTRL + S* to pause the terminal output and *CTRL + Q* to resume.
Alternatively, you may retrieve the key by running the following line while the containers are running:

```
docker exec -it core_ntpd_1 cat /etc/named.conf | grep secret
```

The tsig file then should have the following format:

```
key.docker.ahf.
<key>
```

*The TSIG key usage can currently be bypassed. This is an alpha release. Please do not use if security is a
concern. _(If necessary, though, TSIG usage can be easily enforced by editing the named.conf.template file)_*

*This might open ports in your computer. Please consider this when using this alpha release.*
