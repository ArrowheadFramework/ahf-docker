package se.ltu.ahf.examples.lightcontrol.sensor;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.ParameterException;
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

        Configuration config = Configuration.getInstance();

        try {
             JCommander jCommander = JCommander.newBuilder()
                    .addObject(config)
                    .build();
             jCommander.parse(args);
             if (config.getHelp()) {
                 jCommander.usage();
                 return;
             }
        } catch (ParameterException e) {
            e.usage();
            System.exit(1);
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

