package se.ltu.ahf.docker.proxies.coap;

import org.eclipse.californium.core.CoapServer;
import se.ltu.ahf.docker.proxies.coap.resources.simpleservicediscovery.publish.ServicePublishResource;
import se.ltu.ahf.docker.proxies.coap.resources.simpleservicediscovery.service.ServiceInformationResource;
import se.ltu.ahf.docker.proxies.coap.resources.simpleservicediscovery.type.ServiceTypeResource;
import se.ltu.ahf.docker.proxies.coap.resources.simpleservicediscovery.unpublish.ServiceUnpublishResource;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;

/**
 * Simple proxy for accessing AHF HTTP core services from COAP.
 *
 * TODO: Refactor resource repetition into one or two forwarding resources.
 * Alternatively use Californium's proxy if that works by the time this is worked on.
 */
public class CoapProxy {

    public static void main(String... args) {
        if (!Configuration.load(args)) {
            return;
        }

        CoapProxy coapProxy = new CoapProxy();
        coapProxy.run();

    }

    public void run () {
        Client httpClient = ClientBuilder.newBuilder()
                .sslContext(Configuration.getSslContext())
                .build();

        ServiceInformationResource serviceInformationResource =
                new ServiceInformationResource(httpClient, Configuration.serviceDiscoveryEndpoint);
        ServicePublishResource servicePublishResource =
                new ServicePublishResource(httpClient, Configuration.serviceDiscoveryEndpoint);
        ServiceUnpublishResource serviceUnpublishResource =
                new ServiceUnpublishResource(httpClient, Configuration.serviceDiscoveryEndpoint);
        ServiceTypeResource serviceTypeResource =
                new ServiceTypeResource(httpClient, Configuration.serviceDiscoveryEndpoint);

        CoapServer server = new CoapServer(Configuration.port)
                .add(serviceInformationResource)
                .add(serviceTypeResource)
                .add(serviceUnpublishResource)
                .add(servicePublishResource);
        server.start();
    }
}
