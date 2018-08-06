package se.ltu.ahf.examples.lightcontrol.control;

import org.glassfish.grizzly.http.server.HttpHandler;
import org.glassfish.grizzly.http.server.HttpServer;
import org.glassfish.grizzly.http.server.NetworkListener;
import org.glassfish.grizzly.ssl.SSLContextConfigurator;
import org.glassfish.grizzly.ssl.SSLEngineConfigurator;
import org.glassfish.jersey.grizzly2.httpserver.GrizzlyHttpContainer;
import org.glassfish.jersey.grizzly2.httpserver.GrizzlyHttpContainerProvider;
import org.glassfish.jersey.grizzly2.httpserver.GrizzlyHttpServerFactory;
import org.glassfish.jersey.server.ContainerFactory;
import org.glassfish.jersey.server.ResourceConfig;
import se.ltu.ahf.examples.lightcontrol.control.authorisation.AuthorisationManager;
import se.ltu.ahf.examples.lightcontrol.control.orchestration.OrchestrationConfigurationException;
import se.ltu.ahf.examples.lightcontrol.control.orchestration.OrchestrationManager;
import se.ltu.ahf.examples.lightcontrol.control.servicediscovery.ServiceDiscoveryManager;

import javax.net.ssl.SSLContext;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.core.Application;
import java.net.URI;

public class LightControl {
    private static Client httpClient = ClientBuilder.newBuilder()
            .sslContext(Configuration.initSslContext())
            .build();
    private HttpServer httpServer;


    public LightControl() {
        OrchestrationManager.setHttpClient(httpClient);
        OrchestrationManager.setEndpoint(Configuration.orchestrationEndpoint);
        ServiceDiscoveryManager.setHttpClient(httpClient);
        ServiceDiscoveryManager.setEndpoint(Configuration.serviceDiscoveryEndpoint);
        AuthorisationManager.setHttpClient(httpClient);
        AuthorisationManager.setEndpoint(Configuration.authorisationControlEndpoint);
    }


    public void init() throws OrchestrationConfigurationException {
        /* Register services */
        ServiceDiscoveryManager.publishService(Configuration.getOrchestrationPushServiceInformation(), true);
        ServiceDiscoveryManager.publishService(Configuration.getPresencePushServiceInformation(), true);

        /* Get orchestration configuration */
        OrchestrationManager.init();

        /* Start services */
        startServer("se.ltu.ahf.examples.lightcontrol.control.orchestration.services",
                "se.ltu.ahf.examples.lightcontrol.control.services");

        /* Log */
        System.out.println("Light control system now running. Listening on: ");
        System.out.println(Configuration.baseUri + Configuration.orchestrationPushRelativePath);
        System.out.println(Configuration.baseUri + Configuration.presencePushRelativePath);
    }

    public void close() {
        ServiceDiscoveryManager.unpublishService(Configuration.getOrchestrationPushServiceInformation());
        stopServer();
    }

    private void startServer(String... packages) {
        final ResourceConfig rc = new ResourceConfig().packages(packages);
        SSLContextConfigurator sslContextConfigurator = new SSLContextConfigurator();
        sslContextConfigurator.setKeyStoreFile(Configuration.keyStoreFile);
        sslContextConfigurator.setKeyStorePass(Configuration.keyPassword);
        sslContextConfigurator.setTrustStoreFile(Configuration.trustStoreFile);
        sslContextConfigurator.setTrustStorePass(Configuration.trustStorePassword);
        SSLContext sslContext = sslContextConfigurator.createSSLContext(true);
        HttpHandler httpHandler = ContainerFactory.createContainer(HttpHandler.class, rc);
        this.httpServer = GrizzlyHttpServerFactory.createHttpServer(URI.create(Configuration.baseUri),
                rc, true, new SSLEngineConfigurator(Configuration.getSslContext(), false, true, true));
    }

    private void stopServer() {
        httpServer.shutdownNow();
    }
}
