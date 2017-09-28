package se.ltu.ahf.docker.proxies.coap.resources.simpleservicediscovery.publish;

import org.eclipse.californium.core.server.resources.CoapExchange;
import se.ltu.ahf.docker.proxies.coap.resources.ProxyResource;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;

public class ServicePublishResource extends ProxyResource {

    private static final String DEFAULT_NAME = "publish";

    public ServicePublishResource(Client httpClient, String endpoint) {
        super(DEFAULT_NAME, httpClient, endpoint);
    }

    public ServicePublishResource(String name, Client httpClient, String endpoint) {
        super(name, httpClient, endpoint);
    }

    @Override
    public void handlePOST(CoapExchange exchange) {
        WebTarget webTarget = this.webTarget.path("publish");
        String payload = exchange.getRequestText();

        String responseBody = webTarget.request().post(Entity.xml(payload)).readEntity(String.class);
        exchange.respond(responseBody);
    }

    @Override
    public ServicePublishResource getChild(String name) {
        return this;
    }
}