# Java SE-only example

## Previous steps
Before starting up this container, ensure that you have the necessary core services up
and running. If you are running this from the Arrowhead repository, it should be as
simple as running the following command. You can manually substitute the 
`AHF_DOCKER_PATH` environment variable if you have not set it up previously.

**Linux**
```bash
$ docker-compose up --build ${AHF_DOCKER_PATH}/core
```

**Windows**
```cmd
> docker-compose up --build %AHF_DOCKER_PATH%\core
```

## How to use
**Linux**
```bash
$ docker build -t hello-ahf-java-pure .
$ docker run --rm \
           --name hello-ahf-java-pure \
           --hostname hello.docker.ahf \
           --net-alias hello.docker.ahf \
           -p 8888:8888 \
           --volume core_tls:/tls \
           --network core_ahf \
           hello-ahf-java-pure
```

**Windows**
```cmd
> docker build -t hello-ahf-java-pure .
> docker run --rm ^
           --name hello-ahf-java-pure ^
           --hostname hello.docker.ahf ^
           --net-alias hello.docker.ahf ^
           -p 8888:8888 ^
           --volume core_tls:/tls ^
           --network core_ahf ^
           hello-ahf-java-pure
```

Please note that the network and volume parameters might be different depending
on your environment. The given values should work if you started the the core
containers using docker-compose in the same machine.

If you are planning on connecting to core services on a remote host, you will
need to use a mount volume (i.e. create a Docker volume which allows a directory
on your host to be accessed by containers) and provide the corresponding 
addresses for accessing the remote host. 


## Setup before testing
Before performing the tests below, you need a certificate signed by the 
core/glassfish container's CA. This is automatically done by this container.
Ideally, you should also use the CA to validate the container's response.
This is is also provided.

To retrieve these files, run
```bash
docker cp hello-ahf-java-pure:/client/ .
```  

This will copy the `client/` directory from the container into your current
location. This directory contains the files you need.

```bash
cd client
ls
```  

You should also have curl installed or any other similar application for 
performing web requests.

Finally, your system needs to recognize the hello.docker.ahf host. You can 
achieve this in multiple ways. The easiest being to modify your hosts file to
include the following line (or the corresponding depending on where you are
running the container).

```text
127.0.0.1 hello.docker.ahf
```

## Test calls
### Setup
This endpoint allows the service to register itself on the Service and 
Authorisation Registries. This is for easy demonstration purposes, security
must be considered in real applications.

Currently, the authorisation rule is to allow any caller whose certified name
is `client.docker.ahf` (which is the case for the certificate obtained above).
 
```bash
curl -X POST --cert client.pem:changeit --cacert ca.crt https://hello.docker.ahf:8888/setup
```


### Setdown
This endpoint allows the service to un-register itself from the Service and 
Authorisation Registries. This is for easy demonstration purposes, security
must be considered in real applications. 

```bash
curl -X POST --cert client.pem:changeit --cacert ca.crt https://hello.docker.ahf:8888/setdown
```

### Hello
This is an endpoint set to check the identity of the caller and check for
authorisation in the Authorisation Registry. If the caller is authorised,
the response will be "Hello", otherwise, the response will inform the caller
that they are not authorised.

```bash
curl -X POST --cert client.pem:changeit --cacert ca.crt https://hello.docker.ahf:8888/hello
```

Recommended tests are:

 * Run before doing setup (or after doing setdown).
 * Run after doing setup.
 * Run without providing a certificate (removing the `--cert` parameter).

## Environment variables
By setting any of the following environment variables when running the 
container, you can use it in more complex contexts. For example, you could 
connect to core services on a remote host, or use a different certificate,
obtained from a volume mounted on your host.

### KEYSTORE_LOCATION 
Default: `hello.jks`

### CACERTS_LOCATION 
Default: `ca.jks`

### KEYSTORE_PASSPHRASE 
Default: `changeit`

### SERVICE_DISCOVERY_URL 
Default: `http://simpleservicediscovery.docker.ahf:8045/servicediscovery`

### ORCHESTRATION_URL 
Default: `https://glassfish.docker.ahf:8181/orchestration/store`

### AUTHORISATION_URL 
Default: `http://glassfish.docker.ahf:8080/authorisation`

### AUTHORISATION_CONTROL_URL 
Default: `https://glassfish.docker.ahf:8181/authorisation-control`

### AUTHORIZED_CN 
Default: `client.docker.ahf `

### PORT
Default: `8888`