package se.ltu.ahf.examples.lightcontrol.control.model;

public class PresenceStatus {
    public boolean isSomeonePresent() {
        return someonePresent;
    }

    public void setSomeonePresent(boolean someonePresent) {
        this.someonePresent = someonePresent;
    }

    private boolean someonePresent;
}
