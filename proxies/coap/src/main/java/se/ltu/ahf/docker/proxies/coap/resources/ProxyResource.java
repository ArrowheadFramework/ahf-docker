package se.ltu.ahf.docker.proxies.coap.resources;

import org.eclipse.californium.core.CoapResource;
import org.eclipse.californium.core.server.resources.CoapExchange;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;
import java.util.List;

public class ProxyResource extends CoapResource {

    protected Client httpClient;
    protected WebTarget webTarget;

    public ProxyResource(String name, Client httpClient, String endpoint) {
        super(name);
        this.httpClient = httpClient;
        this.webTarget = httpClient.target(endpoint);
    }

    @Override
    public void handleGET(CoapExchange exchange) {
        WebTarget webTarget = formWebTarget(exchange);
        System.out.println("GET " + webTarget.getUri());
        String responseBody = webTarget.request().get().readEntity(String.class);
        exchange.respond(responseBody);
    }

    @Override
    public void handlePOST(CoapExchange exchange) {
        WebTarget webTarget = formWebTarget(exchange);

        String payload = exchange.getRequestText();
        System.out.println("POST " + webTarget.getUri());
        String responseBody = webTarget.request().post(Entity.xml(payload)).readEntity(String.class);
        exchange.respond(responseBody);
    }

    @Override
    public void handlePUT(CoapExchange exchange) {
        WebTarget webTarget = formWebTarget(exchange);

        String payload = exchange.getRequestText();
        System.out.println("PUT " + webTarget.getUri());
        String responseBody = webTarget.request().put(Entity.xml(payload)).readEntity(String.class);
        exchange.respond(responseBody);
    }

    private WebTarget formWebTarget(CoapExchange exchange) {
        String uriPath = exchange.getRequestOptions().getUriPathString();
        String parentPath = this.getPath().substring(1);
        String relativePath = uriPath.substring(uriPath.indexOf(parentPath) + parentPath.length());
        WebTarget webTarget;

        webTarget = this.webTarget.path(relativePath);

        return webTarget;
    }

    @Override
    public ProxyResource getChild(String name) {
        return this;
    }
}
