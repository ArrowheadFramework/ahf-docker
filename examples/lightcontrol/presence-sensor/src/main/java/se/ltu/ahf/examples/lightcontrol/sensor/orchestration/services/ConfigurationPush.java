package se.ltu.ahf.examples.lightcontrol.sensor.orchestration.services;

import se.ltu.ahf.examples.lightcontrol.sensor.orchestration.OrchestrationConfigurationException;
import se.ltu.ahf.examples.lightcontrol.sensor.orchestration.OrchestrationManager;

import javax.ws.rs.POST;
import javax.ws.rs.Path;

/**
 * OrchestrationConfiguration push resource.
 * Exposes a service to handle configuration pushing.
 *
 * TODO: Extract interface/abstract
 */
@Path("/orchestration/push-config")
public class ConfigurationPush {
    /**
     * Accept incoming configurations and process them.
     *
     * TODO: Support JSON.
     */
    @POST
    public void pushConfiguration() throws OrchestrationConfigurationException {
        OrchestrationManager.update();
    }
}
