package se.ltu.ahf.examples.lightcontrol.sensor.servicediscovery;

import se.ltu.ahf.examples.lightcontrol.sensor.Configuration;
import se.ltu.ahf.examples.lightcontrol.sensor.model.servicediscovery.Service;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;

public final class ServiceDiscoveryManager {

    private static Client httpClient;
    private static WebTarget webTarget;

    public static void setHttpClient(final Client httpClient) {
        ServiceDiscoveryManager.httpClient = httpClient;
    }

    public static void setEndpoint(final String serviceDiscoveryEndpoint) {
        ServiceDiscoveryManager.webTarget = httpClient.target(serviceDiscoveryEndpoint);
    }

    public static void publishService(final Service serviceInformation, final boolean removePrevious) {
        if (removePrevious) {
            unpublishService(serviceInformation);
        }
        webTarget.path("publish")
                .request()
                .post(Entity.xml(serviceInformation))
                .close();
    }

    public static void unpublishService(final Service serviceInformation) {
        System.out.println(Configuration.getInstance().getServiceDiscoveryEndpoint());
        System.out.println(webTarget.getUri());
        webTarget.path("unpublish")
                .request()
                .post(Entity.xml(serviceInformation))
                .close();
    }

    private ServiceDiscoveryManager() {}
}
