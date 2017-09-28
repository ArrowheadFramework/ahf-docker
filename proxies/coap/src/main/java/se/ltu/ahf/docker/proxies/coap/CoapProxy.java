package se.ltu.ahf.docker.proxies.coap;

import org.eclipse.californium.core.CoapServer;
import se.ltu.ahf.docker.proxies.coap.resources.ProxyResource;

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

        String sddEndpoint = Configuration.serviceDiscoveryEndpoint;
        ProxyResource serviceInformationResource = new ProxyResource("service", httpClient, sddEndpoint);
        ProxyResource servicePublishResource = new ProxyResource("publish", httpClient, sddEndpoint);
        ProxyResource serviceUnpublishResource = new ProxyResource("unpublish", httpClient, sddEndpoint);
        ProxyResource serviceTypeResource = new ProxyResource("type", httpClient, sddEndpoint);

        CoapServer server = new CoapServer(Configuration.port)
                .add(serviceInformationResource)
                .add(serviceTypeResource)
                .add(serviceUnpublishResource)
                .add(servicePublishResource);
        server.start();
    }
}
