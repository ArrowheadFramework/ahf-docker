package se.ltu.ahf.examples.lightcontrol.control;

import se.ltu.ahf.examples.lightcontrol.control.orchestration.OrchestrationConfigurationException;

import java.io.IOException;

/**
 * Main class.
 */
public class Main {

    protected static LightControl lightControl;

    /**
     * Main method.
     *
     * @param args
     * @throws IOException
     */
    public static void main(String[] args) throws IOException, OrchestrationConfigurationException {

        Configuration.load(args);
        lightControl = new LightControl();
        lightControl.init();


        /* Handle SIGINT OR SIGTERM. */
        Runtime.getRuntime().addShutdownHook(new Thread(() -> lightControl.close()));

        try {
            while (true) {
                Thread.sleep(1000);
            }
        } catch (InterruptedException e) {
            lightControl.close();
        }
    }
}

