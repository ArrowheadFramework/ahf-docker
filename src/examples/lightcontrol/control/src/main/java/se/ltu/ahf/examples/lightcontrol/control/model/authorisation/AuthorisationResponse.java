package se.ltu.ahf.examples.lightcontrol.control.model.authorisation;

import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "authorisationResponse")
public class AuthorisationResponse {
    private boolean authorised;
    private AuthorisationRequest request;

    public AuthorisationResponse(boolean authorised, AuthorisationRequest request) {
        this.authorised = authorised;
        this.request = request;
    }

    public AuthorisationResponse() {
    }

    public boolean isAuthorised() {
        return authorised;
    }

    public void setAuthorised(boolean authorised) {
        this.authorised = authorised;
    }

    public AuthorisationRequest getRequest() {
        return request;
    }

    public void setRequest(AuthorisationRequest request) {
        this.request = request;
    }
}
