package se.ltu.ahf.examples.lightcontrol.control.model.orchestration;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;
import java.util.List;

@XmlRootElement(name = "orchestrationConfiguration")
public class OrchestrationConfiguration {
    private String lastUpdated;
    private String name;
    private List<String> orchestrationRules;

    public int getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(int serialNumber) {
        this.serialNumber = serialNumber;
    }

    public int getTarget() {
        return target;
    }

    public void setTarget(int target) {
        this.target = target;
    }

    private int serialNumber;
    private int target;

    public String getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(String lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    @XmlElementWrapper
    @XmlElement(name="rule")
    public List<String> getOrchestrationRules() {
        return orchestrationRules;
    }

    public void setOrchestrationRules(List<String> orchestrationRules) {
        this.orchestrationRules = orchestrationRules;
    }

//    public Map<String,String> getRuleMap() {
//        Map<String,String> map = new HashMap<>(orchestrationRules.size());
//        for (OrchestrationRule entry : orchestrationRules) {
//            map.put(entry.getKey(),entry.getVal());
//        }
//        return map;
//    }
}
