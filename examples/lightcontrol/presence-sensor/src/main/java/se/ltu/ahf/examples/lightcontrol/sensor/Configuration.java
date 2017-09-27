package se.ltu.ahf.examples.lightcontrol.sensor;

import org.glassfish.jersey.SslConfigurator;
import se.ltu.ahf.examples.lightcontrol.sensor.model.servicediscovery.Properties;
import se.ltu.ahf.examples.lightcontrol.sensor.model.servicediscovery.Property;
import se.ltu.ahf.examples.lightcontrol.sensor.model.servicediscovery.Service;

import javax.net.ssl.SSLContext;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public final class Configuration {

    private static int port = 8091;
    private static String shortHost = "localhost";
    private static String domain = "docker.ahf";
    static String baseUri = "http://localhost:8091";
    private static String orchestrationPushServiceName = "sensor-module-1-orch-push";
    private static String orchestrationPushServiceType = "_orch-push-rest-http._tcp";
    private static String trustStoreFile;
    private static String trustStoreType;
    private static String trustStorePassword;
    private static String keyStoreFile;
    private static String keyStoreType;
    private static String keyPassword;
    static String serviceDiscoveryEndpoint = "http://127.0.0.1:8045/servicediscovery";
    static String orchestrationEndpoint = "https://glassfish.docker.ahf:8181/orchestration/store/orchestration";
    public static String lightControllerEndpoint;
    private static Map<String, String> argumentMap;

    public static SSLContext getSslContext() {
        return SslConfigurator.newInstance()
                .trustStoreFile(trustStoreFile)
                .trustStoreType(trustStoreType)
                .trustStorePassword(trustStorePassword)
                .keyStoreFile(keyStoreFile)
                .keyStoreType(keyStoreType)
                .keyPassword(keyPassword)
                .createSSLContext();
    }

    static Service getOrchestrationPushServiceInformation() {
        return new Service(
                orchestrationPushServiceName,
                orchestrationPushServiceType,
                domain,
                shortHost,
                port,
                new Properties(Arrays.asList(
                        new Property("version", "1.0"),
                        new Property("path", "/push-orch-config")
                )
                ));
    }

    /* TODO: Consider optionals and defaults. Maybe use a library for this. */
    static boolean load(final String... args) {
        try {
            argumentMap = mapArguments(args);
        } catch (IllegalArgumentException e) {
            printUsageMessage();
            return false;
        }
        updateValues();
        return true;
    }

    private static void printUsageMessage() {
        System.out.println("Missing arguments. These should be given in a space-separated list.");
        System.out.println("For example: parameter1=value1 parameter2=value2");
        System.out.println();
        System.out.println("The available parameters are as follows:");
        Field[] fields = Configuration.class.getDeclaredFields();
        for (Field f : fields) {
            if (Modifier.isPublic(f.getModifiers())) {
                System.out.println(f.getName());
            }
        }
    }

    private static Map<String, String> mapArguments(final String... args) {
        if (args.length == 0) {
            throw new IllegalArgumentException();
        }

        Map<String, String> map = new HashMap<>();
        for (String s : args) {
            String[] keyval = s.split("=");
            if (keyval.length < 2 ||
                    keyval[0] == null ||
                    keyval[1] == null) {
                throw new IllegalArgumentException();
            }
            map.put(keyval[0], keyval[1]);
        }
        return map;
    }

    /* Use reflection */
    private static void updateValues() {
        shortHost = argumentMap.getOrDefault("shortHost", shortHost);
        domain = argumentMap.getOrDefault("domain", domain);
        baseUri = argumentMap.getOrDefault("baseUri", baseUri);
        orchestrationPushServiceName = argumentMap.getOrDefault("orchestrationPushServiceName", orchestrationPushServiceName);
        orchestrationPushServiceType = argumentMap.getOrDefault("orchestrationPushServiceType", orchestrationPushServiceType);
        trustStoreFile = argumentMap.getOrDefault("trustStoreFile", trustStoreFile);
        trustStoreType = argumentMap.getOrDefault("trustStoreType", trustStoreType);
        trustStorePassword = argumentMap.getOrDefault("trustStorePassword", trustStorePassword);
        keyStoreFile = argumentMap.getOrDefault("keyStoreFile", keyStoreFile);
        keyStoreType = argumentMap.getOrDefault("keyStoreType", keyStoreType);
        keyPassword = argumentMap.getOrDefault("keyPassword", keyPassword);
        serviceDiscoveryEndpoint = argumentMap.getOrDefault("serviceDiscoveryEndpoint", serviceDiscoveryEndpoint);
        orchestrationEndpoint = argumentMap.getOrDefault("orchestrationEndpoint", orchestrationEndpoint);
        port = Integer.parseInt(argumentMap.getOrDefault("port", Integer.toString(port)));
    }

    private Configuration() {}
}
