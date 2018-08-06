package se.ltu.ahf.examples.lightcontrol.control.authorisation;

import se.ltu.ahf.examples.lightcontrol.control.model.authorisation.AuthorisationRequest;
import se.ltu.ahf.examples.lightcontrol.control.model.authorisation.AuthorisationResponse;

import javax.ws.rs.client.Client;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;

public final class AuthorisationManager {

    private static Client httpClient;
    private static WebTarget webTarget;

    public static void setHttpClient(final Client httpClient) {
        AuthorisationManager.httpClient = httpClient;
    }

    public static void setEndpoint(final String authorisationControlEndpoint) {
        AuthorisationManager.webTarget = httpClient.target(authorisationControlEndpoint);
    }

    public static AuthorisationResponse requestAuthorisation(final AuthorisationRequest authorisationRequest){
        return webTarget.path("authorisation")
                .request()
                .put(Entity.xml(authorisationRequest))
                .readEntity(AuthorisationResponse.class);
    }

    public static boolean isAuthorised(String distinguishedName, String serviceType, String serviceName) {
        AuthorisationRequest request = new AuthorisationRequest(serviceType,
                serviceName,
                distinguishedName);
        return requestAuthorisation(request).isAuthorised();
    }

}
