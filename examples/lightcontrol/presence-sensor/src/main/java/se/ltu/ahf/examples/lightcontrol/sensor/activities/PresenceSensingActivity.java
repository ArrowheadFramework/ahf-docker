package se.ltu.ahf.examples.lightcontrol.sensor.activities;

import se.ltu.ahf.examples.lightcontrol.sensor.Configuration;

import javax.json.Json;
import javax.json.JsonObject;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.Response;
import java.util.concurrent.TimeUnit;

public class PresenceSensingActivity implements Runnable {

    /* This activity connects to an HTTP service, so we initialize an HTTP client */

    private boolean isSomeonePresent = true;

    private final Client client = ClientBuilder.newBuilder()
            .connectTimeout(500, TimeUnit.MILLISECONDS)
            .readTimeout(500, TimeUnit.MILLISECONDS)
            .sslContext(Configuration.getSslContext()).build();

    @Override
    public void run() {
        Response response = null;
        try {
        /* Perform any scheduled processing */
            System.out.println("Simulating presence change: " + !isSomeonePresent);
            isSomeonePresent = !isSomeonePresent;
            JsonObject payload = Json.createObjectBuilder().add("someonePresent", isSomeonePresent).build();
            WebTarget pushPresenceTarget = client.target(Configuration.lightControllerEndpoint);
            response = pushPresenceTarget.request().put(Entity.json(payload));

            if (response.getStatus() == 200) {
                System.out.println(colorGreen("Presence message received by remote host."));
            } else {
                System.err.println("Message push failed.");
                System.err.println("Response was: " + response.getStatus() + response.getStatusInfo());
            }
        } catch (Throwable e) {
            System.err.println(e.getMessage());
            System.err.println("Verify that the light-control service is running and accepting requests on: ");
            System.err.println(Configuration.lightControllerEndpoint);
        } finally {
            if (response != null) {
                response.close();
            }
        }
    }

    public void close() {
        if (client != null) {
            client.close();
        }
    }

    private String colorGreen(final String s) {
        return (char)27 + "[32m" + s + (char)27 + "[0m";
    }
}
