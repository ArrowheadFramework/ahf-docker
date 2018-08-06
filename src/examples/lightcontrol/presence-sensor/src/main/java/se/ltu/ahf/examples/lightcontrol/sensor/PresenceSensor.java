package se.ltu.ahf.examples.lightcontrol.sensor;

import org.glassfish.grizzly.http.server.HttpServer;
import org.glassfish.jersey.grizzly2.httpserver.GrizzlyHttpServerFactory;
import org.glassfish.jersey.server.ResourceConfig;
import se.ltu.ahf.examples.lightcontrol.sensor.activities.PresenceSensingActivity;
import se.ltu.ahf.examples.lightcontrol.sensor.orchestration.OrchestrationConfigurationException;
import se.ltu.ahf.examples.lightcontrol.sensor.orchestration.OrchestrationManager;
import se.ltu.ahf.examples.lightcontrol.sensor.servicediscovery.ServiceDiscoveryManager;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

class PresenceSensor {
    private HttpServer httpServer;
    private PresenceSensingActivity presenceSensingActivity;
    private Configuration config;


    PresenceSensor() {
        config = Configuration.getInstance();
        Client httpClient = ClientBuilder.newBuilder()
                .sslContext(config.getSslContext())
                .build();
        OrchestrationManager.setHttpClient(httpClient);
        OrchestrationManager.setEndpoint(config.getOrchestrationEndpoint());
        ServiceDiscoveryManager.setHttpClient(httpClient);
        ServiceDiscoveryManager.setEndpoint(config.getServiceDiscoveryEndpoint());
    }

    void init() throws OrchestrationConfigurationException {
        /* Register services */
        ServiceDiscoveryManager.publishService(config.getOrchestrationPushServiceInformation(), true);

        /* Get orchestration configuration */
        OrchestrationManager.init();

        /* Start services */
        startServer("se.ltu.ahf.examples.lightcontrol.sensor.orchestration.services");

        /* Start activities */
        ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();
        presenceSensingActivity = new PresenceSensingActivity();
        executor.scheduleWithFixedDelay(presenceSensingActivity, 1, 4, TimeUnit.SECONDS);

    }

    void close() {
        if (presenceSensingActivity != null) {
            presenceSensingActivity.close();
        }
        ServiceDiscoveryManager.unpublishService(config.getOrchestrationPushServiceInformation());
        stopServer();
    }

    private void startServer(final String... packages) {
        final ResourceConfig rc = new ResourceConfig().packages(packages);
        try {
            this.httpServer = GrizzlyHttpServerFactory.createHttpServer(new URI("https", null, config.getListeningAddress(), config.getPort(), config.getBasePath(), null, null), rc);
        } catch (URISyntaxException e) {
            System.err.println("Error in the selected listening URI (address, port, path).");
            System.err.println("Please re-run using -help if in doubt.");
        }
    }

    private void stopServer() {
        httpServer.shutdownNow();
    }
}
