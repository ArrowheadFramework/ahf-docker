package se.ltu.ahf.docker.proxies.coap.resources.simpleservicediscovery.service;

import org.eclipse.californium.core.server.resources.CoapExchange;
import se.ltu.ahf.docker.proxies.coap.resources.ProxyResource;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.WebTarget;
import java.util.List;

public class ServiceInformationResource extends ProxyResource {

    private static final String DEFAULT_NAME = "service";

    public ServiceInformationResource(Client httpClient, String endpoint) {
        super(DEFAULT_NAME, httpClient, endpoint);
    }

    public ServiceInformationResource(String name, Client httpClient, String endpoint) {
        super(name, httpClient, endpoint);
    }

    @Override
    public void handleGET(CoapExchange exchange) {
        List<String> uriPath = exchange.getRequestOptions().getUriPath();
        WebTarget webTarget;

        if (uriPath.size() > 1) {
            /* Get service by name */
            webTarget = this.webTarget.path("service").path(uriPath.get(1));
        } else {
            /* Get all services */
            webTarget = this.webTarget.path("service");
        }

        String responseBody = webTarget.request().get().readEntity(String.class);
        exchange.respond(responseBody);
    }

    @Override
    public ServiceInformationResource getChild(String name) {
        return this;
    }
}
