package se.ltu.ahf.examples.lightcontrol.sensor;

import com.beust.jcommander.Parameter;
import org.glassfish.jersey.SslConfigurator;
import se.ltu.ahf.examples.lightcontrol.sensor.model.servicediscovery.Properties;
import se.ltu.ahf.examples.lightcontrol.sensor.model.servicediscovery.Property;
import se.ltu.ahf.examples.lightcontrol.sensor.model.servicediscovery.Service;

import javax.net.ssl.SSLContext;
import java.util.Arrays;

public final class Configuration {

    @Parameter(names = {"-shortHost", "-h"}, description = "Hostname to be published on the discovery service without domain. Along with -domain completes the hostname.")
    private String shortHost = "presence-sensor";

    @Parameter(names = {"-domain", "-d"}, description = "Domain to be published on the discovery service. Along with -shortHost completes the hostname.")
    private String domain = "docker.ahf";

    @Parameter(names = {"-listeningHost", "-a", "-l"}, description = "Hostname/IP on which the provided services will listen. The default listens on all interfaces.")
    private String listeningAddress = "0.0.0.0";

    @Parameter(names = {"-port", "-p"}, description = "Port on which the services will listen.")
    private int port = 8091;

    @Parameter(names = {"-basePath", "-b"}, description = "Port on which the main service will run.")
    private String basePath = null;

    @Parameter(names = {"-orchPushServiceName", "-opsn"}, description = "Name to use for publishing the orchestration service.")
    private String orchPushServiceName = "sensor-module-1-orch-push";

    @Parameter(names = {"-orchPushServiceType", "-opst"}, description = "Type of the orchestration service to be published. Must match your local cloud implementation.")
    private String orchPushServiceType = "_orch-push-rest-http._tcp";

    @Parameter(names = {"-trustStoreFile"}, description = "Path of the trust store file to use (cacerts).", required = true)
    private String trustStoreFile = "cacerts.jks";

    @Parameter(names = {"-trustStorePassword"}, description = "Password of the trust store.", required = true)
    private String trustStorePassword = "changeit";

    @Parameter(names = {"-keyStoreFile"}, description = "Path of the keystore file to use (certificate-key / public identity).", required = true)
    private String keyStoreFile = "keystore.jks";

    @Parameter(names = {"-keyStorePassword"}, description = "Password of the keystore.", required = true)
    private String keyStorePassword = "changeit";

    @Parameter(names = {"-serviceDiscoveryEndpoint", "-sd"}, description = "Port on which the main service will run.")
    private String serviceDiscoveryEndpoint = "http://simpleservicediscovery."+ domain + ":8045/servicediscovery";

    @Parameter(names = {"-orchestrationEndpoint", "-orch"}, description = "Port on which the main service will run.")
    private String orchestrationEndpoint = "https://glassfish."+ domain + ":8181/orchestration/store/orchestration";

    @Parameter(names = {"--help", "-help"}, help = true)
    private boolean help;

    private SSLContext sslContext;

    private String lightControlEndpoint;

    private static Configuration instance;

    public SSLContext getSslContext() {
        if (sslContext == null) {
            sslContext = SslConfigurator.newInstance()
                    .trustStoreFile(trustStoreFile)
                    .trustStorePassword(trustStorePassword)
                    .keyStoreFile(keyStoreFile)
                    .keyStorePassword(keyStorePassword)
                    .createSSLContext();
        }
        return sslContext;
    }

    public Service getOrchestrationPushServiceInformation() {
        return new Service(
                orchPushServiceName,
                orchPushServiceType,
                domain,
                shortHost,
                port,
                new Properties(Arrays.asList(
                        new Property("version", "1.0"),
                        new Property("path", "/push-orch-config")
                )
                ));
    }

    public static Configuration getInstance() {
        if (instance == null) {
            instance = new Configuration();
        }
        return instance;
    }

    private Configuration() {}

    public String getShortHost() {
        return shortHost;
    }

    public String getDomain() {
        return domain;
    }

    public String getListeningAddress() {
        return listeningAddress;
    }

    public int getPort() {
        return port;
    }

    public String getBasePath() {
        return basePath;
    }

    public String getOrchPushServiceName() {
        return orchPushServiceName;
    }

    public String getOrchPushServiceType() {
        return orchPushServiceType;
    }

    public String getTrustStoreFile() {
        return trustStoreFile;
    }

    public String getTrustStorePassword() {
        return trustStorePassword;
    }

    public String getKeyStoreFile() {
        return keyStoreFile;
    }

    public String getKeyStorePassword() {
        return keyStorePassword;
    }

    public String getServiceDiscoveryEndpoint() {
        return serviceDiscoveryEndpoint;
    }

    public String getOrchestrationEndpoint() {
        return orchestrationEndpoint;
    }

    public String getLightControlEndpoint() {
        return lightControlEndpoint;
    }

    public void setLightControlEndpoint(String lightControlEndpoint) {
        this.lightControlEndpoint = lightControlEndpoint;
    }

    public boolean getHelp() {
        return help;
    }
}
