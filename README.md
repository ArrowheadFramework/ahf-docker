# Arrowhead Core 3.2 Docker Containers

These containers allow for quicker development on the Arrowhead Framework 3.2
without the need for connecting to an existing _local cloud_. Currently, these
containers are at an alpha stage. Please submit any issues you find or
enhancements you would like to see.

## Usage
Create a Docker network (only needed once).
```bash
docker network create ahf
```

Run the database container.
```bash
docker run --rm \
           --network ahf \
           --publish 3306:3306 \
           --name=ahf-db arrowheadf/db:3.2
```

Run the core services.
```bash
docker run --rm \
           --network ahf \
           --publish 8450:8450 \
           --publish 8451:8451 \
           --env DB_HOST=ahf-db \
           --name=ahf-core arrowheadf/core:3.2
```

Note: To stop the `ahf-db` container, you need to run the following command.
This is because of how the official Docker MySQL image is configured.

```bash
docker stop ahf-db
``` 

## Building from source

The easiest way to get the source code is to download the latest [snapshot of
the
docker.git](https://forge.soa4d.org/anonscm/gitweb?p=arrowhead-f/users/docker.git;a=snapshot;h=refs/heads/3.2;sf=tgz)
repository and extract it.

In the Linux command line, you can use the following commands.

```bash
curl -k -o ahf-docker-3.2.tar.gz \
'https://forge.soa4d.org/anonscm/gitweb?p=arrowhead-f/users/docker.git;a=snapshot;h=refs/heads/3.2;sf=tgz'
mkdir -p ahf-docker-3.2
tar -xvf ahf-docker-3.2.tar.gz -C ahf-docker-3.2 --strip-component=1
cd ahf-docker-3.2
```

Once you have the source code, you can make any necessary modifications and then
build the image.
```bash
docker build -t arrowheadf/core:3.2 core/api/
docker build -t arrowheadf/db:3.2 core/mysql/
```

If you are a developer for the containers, you might want to push any
improvements you make.

```bash
docker push arrowheadf/core:3.2
docker push arrowheadf/db:3.2
```
