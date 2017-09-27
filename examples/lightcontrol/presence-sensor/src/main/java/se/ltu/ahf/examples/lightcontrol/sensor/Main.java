package se.ltu.ahf.examples.lightcontrol.sensor;

import se.ltu.ahf.examples.lightcontrol.sensor.orchestration.OrchestrationConfigurationException;
import java.io.IOException;


/**
 * Main class.
 */
public final class Main {

    private static PresenceSensor presenceSensor;
    private static boolean running = true;

    /**
     * Main method.
     *
     * @param args
     * @throws IOException
     */
    public static void main(final String[] args) throws IOException, OrchestrationConfigurationException {

        if (!Configuration.load(args)) {
            return;
        }

        presenceSensor = new PresenceSensor();
        presenceSensor.init();

        /* Handle SIGINT OR SIGTERM. */
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            presenceSensor.close();
            running = false;
        }));

        try {
            while (running) {
                Thread.sleep(1000);
            }
        } catch (InterruptedException e) {
            presenceSensor.close();
        }
    }

    private Main() {}

}

