package se.ltu.ahf.docker.proxies.coap.resources;

import org.eclipse.californium.core.CoapResource;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.WebTarget;

public class ProxyResource extends CoapResource {

    protected Client httpClient;
    protected WebTarget webTarget;

    public void setHttpClient(final Client httpClient) {
        this.httpClient = httpClient;
    }

    public void setEndpoint(final String endpoint) {
        webTarget = httpClient.target(endpoint);
    }

    public ProxyResource(String name) {
        super(name);
    }

    public ProxyResource(String name, boolean visible) {
        super(name, visible);
    }

    public ProxyResource(String name, Client httpClient, String endpoint) {
        super(name);
        this.httpClient = httpClient;
        setEndpoint(endpoint);
    }
}
