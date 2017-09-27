package se.ltu.ahf.examples.lightcontrol.control.orchestration.services;

import javax.ws.rs.Consumes;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;

/**
 * OrchestrationConfiguration push resource.
 * Exposes a service to handle configuration pushing.
 *
 * TODO: Extract interface/abstract
 */
@Path("/orch/push-config")
public class ConfigurationPush {
    /**
     * Accept incoming configurations and process them.
     *
     * TODO: Support JSON.
     */
    @PUT
    @Consumes(MediaType.APPLICATION_XML)
    public void pushConfiguration() {
        /* TODO: Implement */
    }
}
