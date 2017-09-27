package se.ltu.ahf.examples.lightcontrol.control.services;

import se.ltu.ahf.examples.lightcontrol.control.model.PresenceStatus;

import javax.ws.rs.Consumes;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.Random;

@Path("sensors")
public class PresencePush {
    private static final Random rand = new Random();

    /**
     * Accepts pushes of presence states.
     */
    @PUT
    @Path("presence")
    @Consumes(MediaType.APPLICATION_JSON)
    public Response setPresence(PresenceStatus status) {
        boolean isSomeonePresent = status.isSomeonePresent();
        System.out.println("Presence update message received.");
        System.out.println("New presence is: " + isSomeonePresent);

        // ------------------------
        // Process the request
        // ------------------------
        if (isSomeonePresent) {
            System.out.println("Lights on.");
        } else {
            System.out.println("Lights off.");
        }

        // ------------------------
        // Formulate your response
        // ------------------------
        return Response.ok().build();
    }
}
