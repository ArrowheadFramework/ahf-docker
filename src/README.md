# ahf-docker/src

This directory contains the source for building the Arrowhead Framework 3.0
containers from scratch.

## Instructions for users

### Run

With GIT, Docker and Docker-Compose installed:
```bash
docker-compose --file core/docker-compose.yml -p "ahf" up --build && \
docker-compose --file core/docker-compose.yml -p "ahf" down -v
```

### Test 
```bash
docker-compose --file soapui/docker-compose.yml -p "ahf" up --build && \
docker-compose --file soapui/docker-compose.yml -p "ahf" down -v
```

### Other commands
* To get the auto-generated TLS files, including the Certificate Authority
  certificate and key. 

```bash
sudo cp -far "$(docker volume inspect ahf_tls | 
    grep Mountpoint | 
    sed -E 's/^\s*"\w*"\s*:\s*"(.*)".*$/\1/g')/." . && \
    sudo chown -R $USER:$USER .
```

* To get the auto-generated TSIG file.
```bash
sudo cp -far "$(docker volume inspect ahf_tsig | 
    grep Mountpoint | 
    sed -E 's/^\s*"\w*"\s*:\s*"(.*)".*$/\1/g')/." . && \
    sudo chown -R $USER:$USER .
```

## Commands for developers

Build the images.
```bash
docker build -t arrowheadf/serviceregistry:3.0 core/bind
docker build -t arrowheadf/core:3.0 core/glassfish
docker build -t arrowheadf/simpleservicediscovery:3.0 core/simpleservicediscovery
docker build -t arrowheadf/tests:3.0 soapui
```

Push to Docker Hub. Requires to run `docker login` first.
```bash
docker push arrowheadf/serviceregistry:3.0
docker push arrowheadf/core:3.0
docker push arrowheadf/simpleservicediscovery:3.0
docker push arrowheadf/tests:3.0
```
