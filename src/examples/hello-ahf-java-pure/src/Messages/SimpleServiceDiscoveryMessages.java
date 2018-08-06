package Messages;

public class SimpleServiceDiscoveryMessages {
    public static String SERVICE_PUBLISH_MSG =
            "<service> \n" +
                    "    <domain>docker.ahf</domain>\n" +
                    "    <host>hello.docker.ahf</host>\n" +
                    "    <name>hello-ahf</name>\n" +
                    "    <port>3111</port>\n" +
                    "    <properties>\n" +
                    "    <property>\n" +
                    "       <name>version</name>\n" +
                    "       <value>1.0</value>\n" +
                    "    </property>\n" +
                    "    <property>\n" +
                    "       <name>path</name>\n" +
                    "       <value>/hello</value>\n" +
                    "    </property>\n" +
                    "    </properties>\n" +
                    "    <type>_hello-rest-http._tcp</type>\n" +
                    "</service>";

    public static String SERVICE_UNPUBLISH_MSG =
            "<service>\n" +
                    "    <name>hello-ahf</name>\n" +
                    "</service>";
}
