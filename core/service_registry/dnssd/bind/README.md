# bind

This directory holds a container for running a **bind** server for DNS(-SD)
pre-configured for working with the Arrowhead Framework V3.2 core services.

## Instructions
### Running locally
Build this container by running the following command from this directory.

```bash
docker build --tag ahf-bind .
```

Create a Docker network for other containers to connect to this one. This step
is not necessary if you have created the network previously.

```bash
docker network create ahf
```

Run the container connected to the `ahf` network. 
```bash
docker run --rm --network ahf --name ahf-bind ahf-bind
```
