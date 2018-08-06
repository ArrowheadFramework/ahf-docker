package se.ltu.ahf.examples.lightcontrol.control.model.authorisation;

import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "authorisationRequest")
public class AuthorisationRequest {
    private String serviceType;
    private String serviceName;
    private String distinguishedName;

    public AuthorisationRequest() {
    }

    public AuthorisationRequest(String serviceType, String serviceName, String distinguishedName) {
        this.serviceType = serviceType;
        this.serviceName = serviceName;
        this.distinguishedName = distinguishedName;
    }

    public String getServiceType() {
        return serviceType;
    }

    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public String getDistinguishedName() {
        return distinguishedName;
    }

    public void setDistinguishedName(String distinguishedName) {
        this.distinguishedName = distinguishedName;
    }
}
