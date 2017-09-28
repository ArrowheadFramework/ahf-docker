package se.ltu.ahf.docker.proxies.coap.model.orchestration;

import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "activeConfiguration")
public class ActiveConfiguration {
    private String config;
    private String target;

    public ActiveConfiguration() {}

    public ActiveConfiguration(String config, String target) {
        this.config = config;
        this.target = target;
    }

    public String getConfig() {
        return config;
    }

    public void setConfig(String config) {
        this.config = config;
    }

    public String getTarget() {
        return target;
    }

    public void setTarget(String target) {
        this.target = target;
    }
}
