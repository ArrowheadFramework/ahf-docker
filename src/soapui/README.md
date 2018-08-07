# SoapUI 3.0 container for testing

This is a _dockerized_ version of SoapUI which executes a series of tests to
validate a proper deployment of the Arrowhead Core 3.0 containers.

## Usage
This assumes that you are using the Arrowhead Core 3.0 containers. Specifically,
`arrowheadf/serviceregistry:3.0`, `arrowheadf/core:3.0` and
`arrowheadf/simpleservicediscovery:3.0`.

```bash
docker run --rm \
           --volume tls:/tls \
           --volume tsig:/tsig \
           --hostname soapui.docker.ahf \
           --network ahf \
           --name=ahf-soapui arrowheadf/tests:3.0
```

Alternatively, you can use Docker Compose if you are running the containers from
the source code repository.

```bash
docker-compose --file soapui/docker-compose.yml -p "ahf" up --build && \
docker-compose --file soapui/docker-compose.yml -p "ahf" down -v
```
