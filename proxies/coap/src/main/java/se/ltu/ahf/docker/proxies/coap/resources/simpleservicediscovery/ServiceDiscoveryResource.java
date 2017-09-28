package se.ltu.ahf.docker.proxies.coap.resources.simpleservicediscovery;

import org.eclipse.californium.core.CoapResource;
import org.eclipse.californium.core.server.resources.CoapExchange;

public class ServiceDiscoveryResource extends CoapResource {

    private static final String DEFAULT_NAME = "servicediscovery";

    public ServiceDiscoveryResource() {
        super(DEFAULT_NAME);
    }

    public ServiceDiscoveryResource(String name) {
        super(name);
    }

    @Override
    public void handleGET(CoapExchange exchange) {
        exchange.respond("Something" + getName());
    }
}
