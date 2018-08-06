package se.ltu.ahf.examples.lightcontrol.control.services;

import se.ltu.ahf.examples.lightcontrol.control.Configuration;
import se.ltu.ahf.examples.lightcontrol.control.authorisation.AuthorisationManager;
import se.ltu.ahf.examples.lightcontrol.control.model.PresenceStatus;

import javax.ws.rs.Consumes;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.SecurityContext;
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
    public Response setPresence(@Context SecurityContext securityContext, PresenceStatus status) {

        // ------------------------
        // Authorisation
        // ------------------------
        String callerDistinguishedName = securityContext.getUserPrincipal().getName();

        boolean isAuthorised = AuthorisationManager.isAuthorised(callerDistinguishedName,
                Configuration.presencePushServiceType, Configuration.presencePushServiceName);
        if (!isAuthorised) {
            System.out.println(colorLightRed("Unauthorized attempt. Denied."));
            return Response.status(Response.Status.UNAUTHORIZED).build();
        }

        boolean isSomeonePresent = status.isSomeonePresent();
        System.out.println("Presence update message received.");
        System.out.println("New presence is: " + isSomeonePresent);

        // ------------------------
        // Process the request
        // ------------------------
        if (isSomeonePresent) {
            System.out.println(colorYellow("Lights on."));
        } else {
            System.out.println(colorLightGray("Lights off."));
        }

        // ------------------------
        // Formulate your response
        // ------------------------
        return Response.ok().build();
    }

    private String colorYellow(final String s) {
        return (char)27 +  "[1;33m" + s + (char)27 + "[0m";
    }

    private String colorLightGray(final String s) {
        return (char)27 +  "[30;1m" + s + (char)27 + "[0m";
    }

    private String colorLightRed(final String s) {
        return (char)27 +  "[1;31m" + s + (char)27 + "[0m";
    }
}
