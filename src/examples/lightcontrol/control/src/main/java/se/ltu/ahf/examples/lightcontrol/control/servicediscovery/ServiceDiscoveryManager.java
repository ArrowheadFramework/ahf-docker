package se.ltu.ahf.examples.lightcontrol.control.servicediscovery;

import se.ltu.ahf.examples.lightcontrol.control.model.servicediscovery.Service;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;

public class ServiceDiscoveryManager {

    private static Client httpClient;
    private static WebTarget webTarget;

    public static void setHttpClient(Client httpClient) {
        ServiceDiscoveryManager.httpClient = httpClient;
    }

    public static void setEndpoint(String serviceDiscoveryEndpoint) {
        ServiceDiscoveryManager.webTarget = httpClient.target(serviceDiscoveryEndpoint);
    }

    public static void publishService(Service serviceInformation, boolean removePrevious) {
        if (removePrevious) {
            unpublishService(serviceInformation);
        }
        webTarget.path("publish")
                .request()
                .post(Entity.xml(serviceInformation))
                .close();
    }

    public static void unpublishService(Service serviceInformation) {
        webTarget.path("unpublish")
                .request()
                .post(Entity.xml(serviceInformation))
                .close();
    }
}
