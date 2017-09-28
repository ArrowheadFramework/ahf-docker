package se.ltu.ahf.docker.proxies.coap.resources.simpleservicediscovery.type;

import org.eclipse.californium.core.CoapResource;
import org.eclipse.californium.core.server.resources.CoapExchange;
import se.ltu.ahf.docker.proxies.coap.resources.ProxyResource;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.WebTarget;
import java.util.List;

public class ServiceTypeResource extends ProxyResource {

    private static final String REMOTE_NAME = "type";

    public ServiceTypeResource(Client httpClient, String endpoint) {
        super(REMOTE_NAME, httpClient, endpoint);
    }

    public ServiceTypeResource(String name, Client httpClient, String endpoint) {
        super(name, httpClient, endpoint);
    }

    @Override
    public void handleGET(CoapExchange exchange) {
        List<String> uriPath = exchange.getRequestOptions().getUriPath();
        WebTarget webTarget;

        if (uriPath.size() > 1) {
            /* Get service by name */
            webTarget = this.webTarget.path(REMOTE_NAME).path(uriPath.get(1));
        } else {
            /* Get all services */
            webTarget = this.webTarget.path(REMOTE_NAME);
        }

        String responseBody = webTarget.request().get().readEntity(String.class);
        exchange.respond(responseBody);
    }

    @Override
    public ServiceTypeResource getChild(String name) {
        return this;
    }
}
