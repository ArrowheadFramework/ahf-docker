package se.ltu.ahf.examples.lightcontrol.control;

import org.glassfish.jersey.SslConfigurator;
import se.ltu.ahf.examples.lightcontrol.control.model.servicediscovery.Properties;
import se.ltu.ahf.examples.lightcontrol.control.model.servicediscovery.Property;
import se.ltu.ahf.examples.lightcontrol.control.model.servicediscovery.Service;

import javax.net.ssl.SSLContext;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class Configuration {

    public static int port;
    public static String shortHost;
    public static String domain;
    public static String baseUri;
    public static String orchestrationPushServiceName;
    public static String orchestrationPushServiceType;
    public static String orchestrationPushRelativePath;
    public static String presencePushServiceName;
    public static String presencePushServiceType;
    public static String presencePushRelativePath;
    public static String trustStoreFile;
    public static String trustStoreType;
    public static String trustStorePassword;
    public static String keyStoreFile;
    public static String keyStoreType;
    public static String keyPassword;
    public static String serviceDiscoveryEndpoint;
    public static String orchestrationEndpoint;
    public static String authorisationControlEndpoint;
    public static String lightControllerEndpoint;
    private static Map<String, String> argumentMap;
    private static SSLContext sslContext;

    public static SSLContext initSslContext() {
        sslContext = SslConfigurator.newInstance()
                .trustStoreFile(trustStoreFile)
                .trustStoreType(trustStoreType)
                .trustStorePassword(trustStorePassword)
                .keyStoreFile(keyStoreFile)
                .keyStoreType(keyStoreType)
                .keyStorePassword(keyPassword)
                .createSSLContext();
        return sslContext;
    }

    public static SSLContext getSslContext() {
        if (sslContext == null) return initSslContext();
        return sslContext;
    }

    public static Service getOrchestrationPushServiceInformation() {
        return new Service(
                orchestrationPushServiceName,
                orchestrationPushServiceType,
                domain,
                shortHost,
                port,
                new Properties(Arrays.asList(
                        new Property("version", "1.0"),
                        new Property("path", orchestrationPushRelativePath)
                )
                ));
    }

    public static Service getPresencePushServiceInformation() {
        return new Service(
                presencePushServiceName,
                presencePushServiceType,
                domain,
                shortHost,
                port,
                new Properties(Arrays.asList(
                        new Property("version", "1.0"),
                        new Property("path", presencePushRelativePath)
                )
                ));
    }

    /* TODO: Consider optionals and defaults. Maybe use a library for this. */
    public static boolean load(String[] args) {
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
            if (Modifier.isPublic(f.getModifiers()))
                System.out.println(f.getName());
        }
    }

    private static Map<String, String> mapArguments(String[] args) {
        if (args.length == 0) throw new IllegalArgumentException();

        Map<String, String> map = new HashMap<>();
        for (String s : args) {
            String[] keyval = s.split("=");
            if (keyval == null ||
                    keyval.length < 2 ||
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
        port = !argumentMap.containsKey("port") ? port : Integer.parseInt(argumentMap.get("port"));
        shortHost = !argumentMap.containsKey("shortHost") ? shortHost : argumentMap.get("shortHost");
        domain = !argumentMap.containsKey("domain") ? domain : argumentMap.get("domain");
        baseUri = !argumentMap.containsKey("baseUri") ? baseUri : argumentMap.get("baseUri");
        orchestrationPushServiceName = !argumentMap.containsKey("orchestrationPushServiceName") ? orchestrationPushServiceName : argumentMap.get("orchestrationPushServiceName");
        orchestrationPushServiceType = !argumentMap.containsKey("orchestrationPushServiceType") ? orchestrationPushServiceType : argumentMap.get("orchestrationPushServiceType");
        orchestrationPushRelativePath = !argumentMap.containsKey("orchestrationPushRelativePath") ? orchestrationPushRelativePath : argumentMap.get("orchestrationPushRelativePath");
        presencePushServiceName = !argumentMap.containsKey("presencePushServiceName") ? presencePushServiceName : argumentMap.get("presencePushServiceName");
        presencePushServiceType = !argumentMap.containsKey("presencePushServiceType") ? presencePushServiceType : argumentMap.get("presencePushServiceType");
        presencePushRelativePath = !argumentMap.containsKey("presencePushRelativePath") ? presencePushRelativePath : argumentMap.get("presencePushRelativePath");
        trustStoreFile = !argumentMap.containsKey("trustStoreFile") ? trustStoreFile : argumentMap.get("trustStoreFile");
        trustStoreType = !argumentMap.containsKey("trustStoreType") ? trustStoreType : argumentMap.get("trustStoreType");
        trustStorePassword = !argumentMap.containsKey("trustStorePassword") ? trustStorePassword : argumentMap.get("trustStorePassword");
        keyStoreFile = !argumentMap.containsKey("keyStoreFile") ? keyStoreFile : argumentMap.get("keyStoreFile");
        keyStoreType = !argumentMap.containsKey("keyStoreType") ? keyStoreType : argumentMap.get("keyStoreType");
        keyPassword = !argumentMap.containsKey("keyPassword") ? keyPassword : argumentMap.get("keyPassword");
        serviceDiscoveryEndpoint = !argumentMap.containsKey("serviceDiscoveryEndpoint") ? serviceDiscoveryEndpoint : argumentMap.get("serviceDiscoveryEndpoint");
        orchestrationEndpoint = !argumentMap.containsKey("orchestrationEndpoint") ? orchestrationEndpoint : argumentMap.get("orchestrationEndpoint");
        authorisationControlEndpoint = !argumentMap.containsKey("authorisationControlEndpoint") ? authorisationControlEndpoint : argumentMap.get("authorisationControlEndpoint");
        lightControllerEndpoint = !argumentMap.containsKey("lightControllerEndpoint") ? lightControllerEndpoint : argumentMap.get("lightControllerEndpoint");
    }
}
