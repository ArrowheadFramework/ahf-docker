package se.ltu.ahf.examples.lightcontrol.sensor.orchestration;

import se.ltu.ahf.examples.lightcontrol.sensor.Configuration;
import se.ltu.ahf.examples.lightcontrol.sensor.model.orchestration.ActiveConfiguration;
import se.ltu.ahf.examples.lightcontrol.sensor.model.orchestration.OrchestrationConfiguration;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.HashMap;
import java.util.Map;

public final class OrchestrationManager {

    private static Client httpClient;
    private static WebTarget webTarget;
    private static final Map<String, String> orchestrationRuleMap = new HashMap<>();

    public static void setHttpClient(final Client httpClient) {
        OrchestrationManager.httpClient = httpClient;
    }

    public static void setEndpoint(final String orchestrationEndpoint) {
        webTarget = httpClient.target(orchestrationEndpoint);
    }

    public static void update() throws OrchestrationConfigurationException {
        readOrchestrationConfiguration();
        applyOrchestrationConfiguration();
    }

    public static void init() throws OrchestrationConfigurationException {
        update();
    }

    private static void applyOrchestrationConfiguration() {
        Configuration.lightControllerEndpoint = orchestrationRuleMap.get("light-controller-endpoint");
    }

    private static void readOrchestrationConfiguration() throws OrchestrationConfigurationException {
        /* Get active orchestrationConfiguration name */
        Response response = webTarget.path("active-config")
                .request(MediaType.APPLICATION_XML_TYPE)
                .get();
        if (response.getStatus() != 200) {
            System.err.println("Error getting active orchestrationConfiguration.");
            System.err.println("Response was: " + response.getStatus() + response.getStatusInfo());
            response.close();
            throw new OrchestrationConfigurationException("No active orchestration orchestrationConfiguration");
        }
        ActiveConfiguration activeConfiguration = response.readEntity(ActiveConfiguration.class);
        String activeConfigurationName = activeConfiguration.getConfig();

        /* Get orchestrationConfiguration rules for active orchestrationConfiguration */
        response = webTarget.path("configurations").path(activeConfigurationName)
                .request(MediaType.APPLICATION_XML_TYPE)
                .get();
        if (response.getStatus() != 200) {
            System.err.println("Error getting orchestrationConfiguration rules.");
            System.err.println("Response was: " + response.getStatus() + response.getStatusInfo());
            response.close();
            throw new OrchestrationConfigurationException("Unable to acquire orchestration orchestrationConfiguration " +
                    activeConfigurationName);
        }

        OrchestrationConfiguration orchestrationConfiguration = response.readEntity(OrchestrationConfiguration.class);

        for (String s : orchestrationConfiguration.getOrchestrationRules()) {
            String[] keyval = s.split("=");
            orchestrationRuleMap.put(keyval[0], keyval[1]);
        }
    }

    private OrchestrationManager() {}
}
