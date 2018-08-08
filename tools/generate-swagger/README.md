# Swagger generator

This is a tool for extracting documentation from the JAX-RS implementation of
the core services. All of the services use JAX-RS and therefore all can be
extracted.

_Please note that this is just a containerization around Sebastian Daschner's
thesis result `jaxrs-analyzer` released under the Apache-2.0 license applied to
the Arrowhead Framework 4.0 lightweight core services._

## Usage

First, we need to build the container if we haven't done so already.

```bash
docker build --tag ahf-doc-generator .
```

Then, we will need a directory on which to store our output file(s).

```bash
mkdir -p out
```

Finally, we run the container and direct the output to the desired file path.

```bash
docker run --rm -it ahf-doc-generator > out/arrowhead-core.json
```

This file can be then used or imported into a number of different 
applications and web sites, including Postman, SoapUI, Swagger UI, etc.

The quickest way to make the most out of this file is to open it in [the online 
Swagger Editor](https://editor.swagger.io/). It will let us view all the 
possible end-points, generate client code, and edit the actual file to 
configure it as necessary.

## Usages of Swagger/OpenAPI file

### Simple and quick documentation
You can generate a simple HTML documentation page using the specification 
obtained above.

```bash
docker run --rm -v "${PWD}/out":/local \
    swaggerapi/swagger-codegen-cli generate \
    -i /local/arrowhead-core.json \
    -l "html" \
    -o "/local/html" \
    -DappName="Arrowhead Framework 4.0" \
    -DappDescription="Arrowhead Framework 4.0 - Lightweight" \
    -DinfoUrl="https://forge.soa4d.org/plugins/mediawiki/wiki/arrowhead-f/index.php/Arrowhead_Framework_Wiki" \
    -DinfoEmail="info@arrowhead.eu"
sudo chown -R "$(id -u):$(id -g)" out
```

An alternative format, which contains sample code can be generated instead.

```bash
docker run --rm -v "${PWD}/out":/local \
    swaggerapi/swagger-codegen-cli generate \
    -i /local/arrowhead-core.json \
    -l "html2" \
    -o "/local/html2" \
    -DappName="Arrowhead Framework 4.0" \
    -DappDescription="Arrowhead Framework 4.0 - Lightweight" \
    -DinfoUrl="https://forge.soa4d.org/plugins/mediawiki/wiki/arrowhead-f/index.php/Arrowhead_Framework_Wiki" \
    -DinfoEmail="info@arrowhead.eu"
sudo chown -R "$(id -u):$(id -g)" out
```

The code samples depend on code which [can be generated with this same 
method](#Client code stub generation). 

### Swagger UI

Swagger UI is a user-friendly web-based visual documentation format for any
HTTP-based API. More information, including a [live
demo](https://petstore.swagger.io/) can be found
[here](https://swagger.io/tools/swagger-ui/).

This container can generate a Swagger UI page by passing `gendoc` as a
parameter.

To get the files into a (previously created) directory called `out`, all we have
to do is run the following command.

```bash
docker run --rm -it ahf-doc-generator gendoc | base64 -di | tar -C out -xf -
```

If you are curious about the purpose of `base64` and `tar` there: This is 
used to output all the resulting files without having to mount a Docker 
volume.

If you wanted to share these files with others, you could just get the 
tarball file as follows.

```bash
docker run --rm -it ahf-doc-generator gendoc | base64 -di > out/ahf-ui.tar
```

Note: The full capabilities of Swagger UI might not be available because the 
current version of Arrowhead does not support CORS, which is necessary for 
web applications (such as Swagger UI). Specifically, "try it out" will not 
work on most browsers unless you do _hacky stuff_.

### Client code stub generation
To bootstrap your development process, you can generate client code by using 
the Swagger specification file obtained above. One way to achieve this has 
already been mentioned.

Another way, which does not require a browser, is by running the following 
commands.

First we need the `openapi-generator-cli` image. We only need to do this once.

```bash
docker pull openapitools/openapi-generator-cli
```

Then we can generate client stubs for a number of languages. For Java, we 
would run the following.

```bash
client_language="java"
docker run --rm -v "${PWD}/out":/local \
    swaggerapi/swagger-codegen-cli generate \
    -i /local/arrowhead-core.json \
    -l "$client_language" \
    -o "/local/$client_language"
sudo chown -R "$(id -u):$(id -g)" out
```

This will generate a number of Java classes, including annotated domain model
POJOs for serializing requests and responses.

Note above that we change the ownership of the resulting files using `chown`
because otherwise they will be read-only.

The list of languages is as follows.

```
ada
android
apache2
apex
aspnetcore
bash
clojure
cwiki
cpp-qt5
cpp-restsdk
cpp-tizen
csharp
csharp-dotnet2
csharp-nancyfx
dart
eiffel
elixir
elm
erlang-client
flash
scala-finch
go
groovy
kotlin
haskell-http-client
haskell
java
jaxrs-cxf-client
java-inflector
java-msf4j
java-pkmst
java-play-framework
java-vertx
jaxrs-cxf
jaxrs-cxf-cdi
jaxrs-jersey
jaxrs-resteasy
jaxrs-resteasy-eap
jaxrs-spec
javascript
javascript-flowtyped
javascript-closure-angular
jmeter
lua
objc
openapi
openapi-yaml
perl
php
php-laravel
php-lumen
php-slim
php-silex
php-symfony
php-ze-ph
powershell
python
python-flask
r
ruby
ruby-on-rails
ruby-sinatra
rust
scalatra
scala-akka
scala-httpclient
scala-gatling
scalaz
spring
dynamic-html
html
html2
swift3
swift4
typescript-angular
typescript-angularjs
typescript-aurelia
typescript-fetch
typescript-inversify
typescript-jquery
typescript-node
```



