package se.ltu.ahf.docker.proxies.coap.resources;

import org.eclipse.californium.core.CoapResource;

public class OrchestrationManagement extends CoapResource {
    public OrchestrationManagement(String name) {
        super(name);
    }

    public OrchestrationManagement(String name, boolean visible) {
        super(name, visible);
    }
}
