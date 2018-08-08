# Swagger generator

This is a tool for extracting documentation from the JAX-RS implementation of
the core services. All of the services use JAX-RS and therefore all can be
extracted.

_Please note that this is just a containerization around Sebastian Daschner's
thesis result `jaxrs-analyzer` released under the Apache-2.0 license applied to
the Arrowhead Framework 3.2 core services by AITIA International Inc._

Assuming you were interested in extracting documentation for the authorization
control service, you would do the following: 

```bash
docker build --tag tools-generate-payloads .
docker run --rm -it tools-generate-payloads authorization > auth-ctrl.json
```

Then, you can go to [the Swagger Editor](https://editor.swagger.io/) and use
this file to view the documentation in a nice format and generate client stubs.

The idea is for this container to also generate the documentation as a HTML
document without the need to go to through the swagger editor, but please be
patient.

This could also be then used to generate documentation in other formats, and
that might be done in the future. 

## Examples

```bash
docker run --rm -it tools-generate-payloads authorization > auth-ctrl.json
```

```bash
docker run --rm -it tools-generate-payloads serviceregistry > sr.json
```

```bash
docker run --rm -it tools-generate-payloads orchestrator > orch.json
```

```bash
docker run --rm -it tools-generate-payloads gatekeeper > gatekeeper.json
```

```bash
docker run --rm -it tools-generate-payloads gateway > gateway.json
```

```bash
docker run --rm -it tools-generate-payloads qos > qos.json
```

```bash
docker run --rm -it tools-generate-payloads api > api.json
```


