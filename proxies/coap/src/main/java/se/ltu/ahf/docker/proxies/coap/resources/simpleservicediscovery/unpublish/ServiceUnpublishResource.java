package se.ltu.ahf.docker.proxies.coap.resources.simpleservicediscovery.unpublish;

import org.eclipse.californium.core.server.resources.CoapExchange;
import se.ltu.ahf.docker.proxies.coap.resources.ProxyResource;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;

public class ServiceUnpublishResource extends ProxyResource {

    private static final String REMOTE_NAME = "unpublish";

    public ServiceUnpublishResource(Client httpClient, String endpoint) {
        super(REMOTE_NAME, httpClient, endpoint);
    }

    public ServiceUnpublishResource(String name, Client httpClient, String endpoint) {
        super(name, httpClient, endpoint);
    }

    @Override
    public void handlePOST(CoapExchange exchange) {
        WebTarget webTarget = this.webTarget.path(REMOTE_NAME);
        String payload = exchange.getRequestText();

        String responseBody = webTarget.request().post(Entity.xml(payload)).readEntity(String.class);
        exchange.respond(responseBody);
    }

    @Override
    public ServiceUnpublishResource getChild(String name) {
        return this;
    }
}
