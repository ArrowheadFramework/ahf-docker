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
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

class PresenceSensor {
    private static Client httpClient = ClientBuilder.newBuilder()
            .sslContext(Configuration.getSslContext())
            .build();
    private HttpServer httpServer;
    private PresenceSensingActivity presenceSensingActivity;


    PresenceSensor() {
        OrchestrationManager.setHttpClient(httpClient);
        OrchestrationManager.setEndpoint(Configuration.orchestrationEndpoint);
        ServiceDiscoveryManager.setHttpClient(httpClient);
        ServiceDiscoveryManager.setEndpoint(Configuration.serviceDiscoveryEndpoint);
    }

    void init() throws OrchestrationConfigurationException {
        /* Register services */
        ServiceDiscoveryManager.publishService(Configuration.getOrchestrationPushServiceInformation(), true);

        /* Get orchestration configuration */
        OrchestrationManager.init();

        /* Start services */
        startServer("se.ltu.ahf.examples.lightcontrol.sensor.orchestration.services");

        /* Start activities */
        ScheduledExecutorService executor = Executors.newSingleThreadScheduledExecutor();
        presenceSensingActivity = new PresenceSensingActivity();
        executor.scheduleWithFixedDelay(presenceSensingActivity, 10, 10, TimeUnit.SECONDS);

    }

    void close() {
        if (presenceSensingActivity != null) {
            presenceSensingActivity.close();
        }
        ServiceDiscoveryManager.unpublishService(Configuration.getOrchestrationPushServiceInformation());
        stopServer();
    }

    private void startServer(final String... packages) {
        final ResourceConfig rc = new ResourceConfig().packages(packages);
        this.httpServer = GrizzlyHttpServerFactory.createHttpServer(URI.create(Configuration.baseUri), rc);
    }

    private void stopServer() {
        httpServer.shutdownNow();
    }
}
