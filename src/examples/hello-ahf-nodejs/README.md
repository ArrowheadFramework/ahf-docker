# NodeJS example

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
           --volume tls:/tls \
           --network ahf \
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
 
## Other usage scenarios
### Resin with bootstrapping
[Optional] Ensure that the core containers are already running.
```bash
docker-compose up -f ../../core
```

[Optional] Ensure that the core containers are bootstrap-publishing.
```bash
SERVER_ADDRESS=$(docker inspect -f "{{ .NetworkSettings.Networks.core_ahf.IPAddress }}" core_bind_1)
[ -n "SERVER_ADDRESS" ] && \
docker run \
       --rm \
       --network core_ahf \
       --ip 192.168.10.121 \
       --env URI_SCHEME="dns" \
       --env URI_HOST="${SERVER_ADDRESS}" \
       --env IP_ADDRESS="${SERVER_ADDRESS}" \
       --env MCAST_INTERFACE="192.168.10.121" \
       --name socat-bootstrap-server \
       socat-bootstrap-server
```

[Optional] Remove the Docker network.
```bash
docker -H tcp://resin1.local:2375 network rm mcast_net
```

[Optional] Recreate it.
```bash
docker -H tcp://resin1.local:2375 network create \
             -d macvlan \
             --subnet=192.168.10.0/24 \
             --gateway=192.168.10.180 \
             -o parent=eth0 \
             mcast_net
```

[Optional] Create and fill the tls volume (assumes core is running locally)
```bash
docker -H tcp://resin1.local:2375 volume create tls 
docker -H tcp://resin1.local:2375 run --rm --name temp --volume tls:/tls -dit alpine
docker cp core_glassfish_1:/tls/ .
cd tls
keytool -import \
    -trustcacerts \
    -alias "ca" \
    -file "ca.crt" \
    -keystore "ca.jks" \
    -storepass "changeit" \
    -noprompt
sed -i '$ d' generate-signed-cert.sh
./generate-signed-cert.sh hello-ahf hello.docker.ahf changeit
./generate-signed-cert.sh client client.docker.ahf changeit
mkdir -p ../client
mv client* ca.crt ../client
docker -H tcp://resin1.local:2375 cp . temp:/tls/
cd ..
docker -H tcp://resin1.local:2375 stop temp
rm -rf tls
```

(Another idea when running all locally -- should build tool container... this requires downloading something extra)
```bash
docker volume create tls
docker volume create tsig
docker run \
       --rm \
       -it \
       --volume core_tls:/core_tls \
       --volume core_tsig:/core_tsig \
       --volume tls:/tls \
       --volume tsig:/tsig \
       openjdk:8-jdk-alpine
apk --no-cache add openssl
cd /core_tls
keytool -import \
    -trustcacerts \
    -alias "ca" \
    -file "ca.crt" \
    -keystore "ca.jks" \
    -storepass "changeit" \
    -noprompt
./generate-signed-cert.sh hello-ahf hello.docker.ahf changeit
./generate-signed-cert.sh client client.docker.ahf changeit
cp -f ./* /tls
cp -f /core_tsig/tsig /tsig
exit;
```

Build the images.
```bash
docker -H tcp://resin1.local:2375 build \
            --tag socat-bootstrap-client \
            ../../discovery-bootstrapping/multicast/plain/socat/client
docker -H tcp://resin1.local:2375 build \
            --tag hello-ahf-nodejs .
```

Run the containers.
```bash
docker -H tcp://resin1.local:2375 run \
           --rm \
           --network mcast_net \
           --ip 192.168.10.181 \
           --name socat-bootstrap-client \
           --env OUTPUT_FILENAME="bootstrap" \
           --volume bootstrapping:/out \
           socat-bootstrap-client
docker -H tcp://resin1.local:2375 run \
           --rm \
           --network mcast_net \
           --ip 192.168.10.182 \
           --name hello-ahf-nodejs \
           --hostname hello.docker.ahf \
           -p 3111:3111 \
           --volume tls:/tls \
           --volume bootstrapping:/boots \
           --env BOOTSTRAPPING_PATH="/boots/bootstrap" \
           hello-ahf-nodejs
```

Set the hosts file for the current location of the container
```bash
sudo sed -Ei "s/^[1-9].*hello\.docker\.ahf/127.0.0.1 hello.docker.ahf/g" /etc/hosts
```

Test
```bash
curl -X GET --cert client/client.pem:changeit --cacert client/ca.crt https://hello.docker.ahf:3111/setup
curl -X GET --cert client/client.pem:changeit --cacert client/ca.crt https://hello.docker.ahf:3111/hello
curl -X GET --cert client/client.pem:changeit --cacert client/ca.crt https://hello.docker.ahf:3111/setdown
curl -X GET --cert client/client.pem:changeit --cacert client/ca.crt https://hello.docker.ahf:3111/hello
```

Clean up
```bash
rm -rf client
```

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

### BOOTSTRAPPING_PATH
No default.




### Virtualbox demo execute from ahf-docker/
Missing:
* Hello must register itself with DNS

Preparation:
* Might need to open ports inside the NAT? I assume they are just not closed in the local network.
* Create TLS and TSIG in VM 1
* Copy them to VM 2 and VM 3

Steps:
VM 1:
* Run the core containers detached
* Run DNS bootstrapper detached same VM

VM 2:
* Run bootstrapper leading to volume
* Run hello-nodejs connected to bootstrapping, TLS and TSIG volumes with the necessary port open

VM 3:
* Run test calls to hello-nodejs

* Start the VMs
```bash
VBoxManage startvm ud1 --type headless
VBoxManage startvm ud2 --type headless
VBoxManage startvm ud3 --type headless
ssh r@10.0.0.1 -p22222
ssh r@10.0.0.2 -p22222
ssh r@10.0.0.3 -p22222
```


* Create TLS and TSIG in VM 1
```bash
docker-compose -f core/docker-compose.yml run glassfish tls
```

* Copy them to removable media
```bash
mkdir -p .media/tls .media/tsig
sudo cp -far "$(docker volume inspect core_tls -f '{{ .Mountpoint }}')/." .media/tls/ && sudo chown -R ${USER}:${USER} .media/tls

cd .media/tls
keytool -import \
    -trustcacerts \
    -alias "ca" \
    -file "ca.crt" \
    -keystore "ca.jks" \
    -storepass "changeit" \
    -noprompt
./generate-signed-cert.sh hello-ahf hello.docker.ahf changeit
./generate-signed-cert.sh client client.docker.ahf changeit
cd -
sudo cp -far "$(docker volume inspect core_tsig -f '{{ .Mountpoint }}')/." .media/tsig/ && sudo chown -R ${USER}:${USER} .media/tls
device_path=/dev/sda1
sudo umount .media
sudo mount "${device_path}" .media && \
cp -far tls tsig .media/
sudo umount .media
rm -rf .media
```

* Copy them to VM 2 and VM 3
On VM 1
```bash
mkdir -p ~/tls ~/tsig;
sudo cp -far "$(docker volume inspect core_tls -f '{{ .Mountpoint }}')/." ~/tls/ && sudo chown -R ${USER}:${USER} ~/tls; 
sudo cp -far "$(docker volume inspect core_tsig -f '{{ .Mountpoint }}')/." ~/tsig/ && sudo chown -R ${USER}:${USER} ~/tsig;
```

On the host
```bash
# TODO: Check contents
scp -P 22222 -r r@10.0.0.1:~/tls/ tls
scp -P 22222 -r r@10.0.0.1:~/tsig/ tsig
cd tls
keytool -import \
    -trustcacerts \
    -alias "ca" \
    -file "ca.crt" \
    -keystore "ca.jks" \
    -storepass "changeit" \
    -noprompt
./generate-signed-cert.sh hello-ahf hello.docker.ahf changeit
./generate-signed-cert.sh client client.docker.ahf changeit
cd -
scp -P 22222 -r tls/ tsig/ r@10.0.0.2:~/
scp -P 22222 -r tls/ tsig/ r@10.0.0.3:~/
rm -rf tls/ tsig/
```

[Optional] Ensure that the core containers are already running.
```bash
docker-compose -f ~/ahf-docker/core/docker-compose.yml up -d
```

[Optional] Ensure that the core containers are bootstrap-publishing.
```bash
docker build \
       --tag socat-bootstrap-server \
       ~/ahf-docker/discovery-bootstrapping/multicast/plain/socat/core/
docker run \
       --restart always \
       --detach \
       --network host \
       --env URI_SCHEME="dns" \
       --env PUBLISH_INTERFACE_NAME="enp0s3" \
       --env MCAST_INTERFACE_NAME="enp0s3" \
       --name socat-bootstrap-server \
       socat-bootstrap-server
```

[Optional] Remove the Docker network.
```bash
docker network rm mcast_net
```

[Optional] Recreate it.
```bash
docker network create \
             -d macvlan \
             --subnet=192.168.10.0/24 \
             --gateway=192.168.10.180 \
             -o parent=eth0 \
             mcast_net
```

[Optional] Create and fill the tls and tsig volumes (VM2)
```bash
docker volume create tls
docker volume create tsig
docker run --rm --name temp --volume tls:/tls --volume tsig:/tsig -dit alpine
docker cp ~/tls/. temp:/tls/
docker cp ~/tsig/. temp:/tsig/
docker stop temp
rm -rf tls
```

Build the images.
```bash
scp -P 22222 -r ~/ws/ahf-docker/ r@10.0.0.2:~/
```
```bash
docker build \
            --tag socat-bootstrap-client \
            ~/ahf-docker/discovery-bootstrapping/multicast/plain/socat/client
docker stop hello-ahf-nodejs
docker rm hello-ahf-nodejs
docker build \
            --tag hello-ahf-nodejs \
            ~/ahf-docker/examples/hello-ahf-nodejs
```

Run the containers.
```bash
docker volume create bootstrapping
docker run \
           --rm \
           --network host \
           --name socat-bootstrap-client \
           --env OUTPUT_FILENAME="bootstrap" \
           --volume bootstrapping:/out \
           socat-bootstrap-client
docker run \
           --rm \
           --network host \
           --name hello-ahf-nodejs \
           --hostname hello.docker.ahf \
           -p 3111:3111 \
           --volume tls:/tls \
           --volume tsig:/tsig \
           --volume bootstrapping:/boots \
           --env REGISTER_WITH_DNS=true \
           --env BOOTSTRAPPING_PATH="/boots/bootstrap" \
           hello-ahf-nodejs
```

Alternatively, run the containers detached and to restart always.
```bash
docker volume create bootstrapping
docker run \
           --restart always \
           --detach \
           --network host \
           --name socat-bootstrap-client \
           --env OUTPUT_FILENAME="bootstrap" \
           --volume bootstrapping:/out \
           socat-bootstrap-client
docker run \
           --restart always \
           --detach \
           --network host \
           --name hello-ahf-nodejs \
           --hostname hello.docker.ahf \
           -p 3111:3111 \
           --volume tls:/tls \
           --volume tsig:/tsig \
           --volume bootstrapping:/boots \
           --env REGISTER_WITH_DNS=true \
           --env BOOTSTRAPPING_PATH="/boots/bootstrap" \
           --env IP_INTERFACE_NAME="enp0s3" \
           --env DO_DYNAMIC_DNS_UPDATE=true \
           hello-ahf-nodejs
```

Get the DNS server on the client
```bash
docker run \
           --rm \
           --network host \
           --name socat-bootstrap-client \
           --env OUTPUT_FILENAME="bootstrap" \
           --volume bootstrapping:/out \
           socat-bootstrap-client | sed -E 's/.* (.*)/nameserver \1/g' > resolv.conf
sudo cp -f {.,/etc}/resolv.conf
ping glassfish.docker.ahf
ping hello.docker.ahf
```

Test
```bash
curl -X GET --cert ~/tls/client.pem:changeit --cacert ~/tls/ca.crt https://hello.docker.ahf:3111/setup
curl -X GET --cert ~/tls/client.pem:changeit --cacert ~/tls/ca.crt https://hello.docker.ahf:3111/hello
curl -X GET --cert ~/tls/client.pem:changeit --cacert ~/tls/ca.crt https://hello.docker.ahf:3111/setdown
curl -X GET --cert ~/tls/client.pem:changeit --cacert ~/tls/ca.crt https://hello.docker.ahf:3111/hello
```

Change net
```bash
VBoxManage controlvm "ud1" nic1 natnetwork net192 && \
VBoxManage controlvm "ud2" nic1 natnetwork net192 && \
VBoxManage controlvm "ud3" nic1 natnetwork net192

sudo systemctl restart networking.service
```

Clean up
Host
```bash
VBoxManage controlvm "ud1" nic1 natnetwork net10 && \
VBoxManage controlvm "ud2" nic1 natnetwork net10 && \
VBoxManage controlvm "ud3" nic1 natnetwork net10
VBoxManage controlvm "ud1" acpipowerbutton
VBoxManage controlvm "ud2" acpipowerbutton
VBoxManage controlvm "ud3" acpipowerbutton
```
All VMS
```bash
sudo systemctl restart networking.service
```

* Start the VMs
```bash
VBoxManage startvm ud1 --type headless
VBoxManage startvm ud2 --type headless
VBoxManage startvm ud3 --type headless
ssh r@10.0.0.1 -p22222
ssh r@10.0.0.2 -p22222
ssh r@10.0.0.3 -p22222
```

VM 3
```bash
sudo cp -f /etc/resolv.conf{.bkp,}
rm -rf client
```

Extra
```bash
vm=ud3 && VBoxManage controlvm "$vm" nic1 natnetwork net192 && VBoxManage controlvm $vm setlinkstate1 off && VBoxManage controlvm $vm setlinkstate1 on
```
```bash
VBoxManage controlvm ud1 setlinkstate1 off
VBoxManage controlvm ud2 setlinkstate1 off
VBoxManage controlvm ud3 setlinkstate1 off
VBoxManage controlvm ud1 setlinkstate1 on
VBoxManage controlvm ud2 setlinkstate1 on
VBoxManage controlvm ud3 setlinkstate1 on
```

