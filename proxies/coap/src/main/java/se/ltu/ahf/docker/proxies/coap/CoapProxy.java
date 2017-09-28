package se.ltu.ahf.docker.proxies.coap;

import org.eclipse.californium.core.CoapResource;
import org.eclipse.californium.core.CoapServer;
import se.ltu.ahf.docker.proxies.coap.resources.ProxyResource;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;

/**
 * Simple proxy for accessing AHF HTTP core services from COAP.
 *
 * It registers all the resources to make them discoverable.
 * This is not necessary. Consider removing it and leaving a very simple implementation.
 *
 * TODO: Move resource locations to configuration.
 * TODO: Add security.
 * TODO: Consider refactoring to use Californium's own proxy.
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
        CoapResource serviceDiscoveryRootResource = new CoapResource("servicediscovery");
        ProxyResource serviceInformationResource = new ProxyResource("service", httpClient, sddEndpoint);
        ProxyResource servicePublishResource = new ProxyResource("publish", httpClient, sddEndpoint);
        ProxyResource serviceUnpublishResource = new ProxyResource("unpublish", httpClient, sddEndpoint);
        ProxyResource serviceTypeResource = new ProxyResource("type", httpClient, sddEndpoint);

        String authConfigEndpoint = Configuration.authorisationConfigurationEndpoint;
        CoapResource authConfigRootResource = new CoapResource("authorisation");
        ProxyResource authConfigSoapServiceResource = new ProxyResource("AuthorisationConfigurationService", httpClient, authConfigEndpoint);

        String authControlEndpoint = Configuration.authorisationControlEndpoint;
        CoapResource authControlRootResource = new CoapResource("authorisation-control");
        ProxyResource authRequestResource = new ProxyResource("authorisation", httpClient, authControlEndpoint);

        CoapResource orchestrationRootResource = new CoapResource("orchestration");

        String orchManagementEndpoint = Configuration.orchestrationManagementEndpoint;
        CoapResource orchManagementRootResource = new CoapResource("mgmt");
        ProxyResource orchManagementConfigurationsResource = new ProxyResource("configurations", httpClient, orchManagementEndpoint);
        ProxyResource orchManagementTargetsResource = new ProxyResource("targets", httpClient, orchManagementEndpoint);
        ProxyResource orchManagementActiveConfigResource = new ProxyResource("active-config", httpClient, orchManagementEndpoint);

        /* Those below depend on the certificate used in this server! */
        String orchStoreEndpoint = Configuration.orchestrationStoreEndpoint;
        CoapResource orchStoreRootResource = new CoapResource("store");
        ProxyResource orchStoreConfigurationsResource = new ProxyResource("configurations", httpClient, orchStoreEndpoint);
        ProxyResource orchStoreActiveConfigResource = new ProxyResource("active-config", httpClient, orchStoreEndpoint);

        CoapServer server = new CoapServer(Configuration.port)
                .add(serviceDiscoveryRootResource
                    .add(serviceInformationResource)
                    .add(serviceTypeResource)
                    .add(serviceUnpublishResource)
                    .add(servicePublishResource))
                .add(authControlRootResource
                        .add(authRequestResource))
                .add(authConfigRootResource
                        .add(authConfigSoapServiceResource))
                .add(orchestrationRootResource
                        .add(orchManagementRootResource
                                .add(orchManagementTargetsResource)
                                .add(orchManagementActiveConfigResource)
                                .add(orchManagementConfigurationsResource))
                        .add(orchStoreRootResource
                                .add(orchStoreConfigurationsResource)
                                .add(orchStoreActiveConfigResource)));
        server.start();
    }
}
