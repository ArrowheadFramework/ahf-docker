# Docker: Database 3.2

This is a _dockerized_ version of the MySQL/MariaDB database pre-configured for
working with the Arrowhead Framework V3.2 core services.

## Instructions

## Usage
First, create a Docker network for other containers to connect to this one. This
step is not necessary if you have created the network previously.

```bash
docker network create ahf
```

Then, run the database container.
```bash
docker run -t --rm \
           --network ahf \
           --publish 3306:3306 \
           --name=ahf-db arrowheadf/db:3.2
```

To stop the container, you need to run the following command. This is because of
how the official Docker MySQL image is configured.

```bash
docker stop ahf-db
``` 

## Environment Variables

The environment variables in this container are the same as for the official
MySQL Docker one.

* `MYSQL_ROOT_PASSWORD`
* `MYSQL_DATABASE`
* `MYSQL_USER, MYSQL_PASSWORD`
* `MYSQL_ALLOW_EMPTY_PASSWORD`
* `MYSQL_RANDOM_ROOT_PASSWORD`
* `MYSQL_ONETIME_PASSWORD`
