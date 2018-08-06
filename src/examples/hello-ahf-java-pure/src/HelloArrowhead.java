/*
For the following to work outside of a container, you might want to add the following lines to your hosts file:
    127.0.0.1 simpleservicediscovery.docker.ahf
    127.0.0.1 glassfish.docker.ahf

Additionally, two files must be provided:
- A Java keystore (JKS) with the private and public keys for the application (both as client and server).
- A JKS file with ONLY the public certificate of the CA being used (as client and server).

The reason the CA JKS must contain ONLY the -one- public certificate and no keys is because of a potential bug in the
Java source code. If using external libraries, this would probably not be an issue. The problem is discussed by
http://blog.palominolabs.com/2011/10/18/java-2-way-tlsssl-client-certificates-and-pkcs12-vs-jks-keystores/index.html
*/

import Messages.AuthorisationMessages;
import Messages.SimpleServiceDiscoveryMessages;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpsConfigurator;
import com.sun.net.httpserver.HttpsExchange;
import com.sun.net.httpserver.HttpsParameters;
import com.sun.net.httpserver.HttpsServer;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLParameters;
import javax.net.ssl.SSLPeerUnverifiedException;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManagerFactory;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.InetSocketAddress;
import java.net.MalformedURLException;
import java.net.URL;
import java.security.KeyManagementException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.util.HashMap;
import java.util.Map;

public class HelloArrowhead implements HttpHandler {
    private static final String[] REQUIRED_PROPERTIES = {
            "keystoreLocation",
            "cacertsLocation",
            "keystorePassphrase",
            "serviceDiscoveryUrl",
            "orchestrationUrl",
            "authorisationUrl",
            "authorisationControlUrl",
            "authorizedCn",
            "hostname",
            "port"
    };

    private static final Map<String, String> PROPERTIES = new HashMap<>();

    private HttpsServer httpServer;
    private SSLContext sslContext = null;

    private HelloArrowhead() {
    }

    public static void main(String... args) {
        final HelloArrowhead application = new HelloArrowhead();

        /* Load configuration -- Uses system properties for simplicity */
        for (String propName : REQUIRED_PROPERTIES) {
            String propValue = System.getProperty(propName);
            if (propValue == null) {
                printUsageInformation();
                System.exit(0);
            }
            PROPERTIES.put(propName, propValue);
        }

        application.start();
    }

    private static void printUsageInformation() {
        System.out.println("Usage:");
        System.out.println("\t  java \\\n" +
                "    -DkeystoreLocation=${KEYSTORE_LOCATION} \\\n" +
                "    -DcacertsLocation=${CACERTS_LOCATION} \\\n" +
                "    -DkeystorePassphrase=${KEYSTORE_PASSPHRASE} \\\n" +
                "    -DserviceDiscoveryUrl=${SERVICE_DISCOVERY_URL} \\\n" +
                "    -DorchestrationUrl=${ORCHESTRATION_URL} \\\n" +
                "    -DauthorisationUrl=${AUTHORISATION_URL} \\\n" +
                "    -DauthorisationControlUrl=${AUTHORISATION_CONTROL_URL} \\\n" +
                "    -DauthorizedCn=${AUTHORIZED_CN} \\\n" +
                "    -Dhostname=$(hostname -f) \\\n" +
                "    -Dport=${PORT} \\\n" +
                "    HelloArrowhead");
    }

    /**
     * Starts the HelloArrowhead application.
     * <p>
     * It registers a shutdown hook which gets automatically called by the JVM when the application is closing.
     * This is used to stop the server cleanly (ref. stop()).
     * <p>
     * The main operation, however, is to create the HTTP server on port 8888 with a null backlog (we don't expect any
     * real traffic, so this is irrelevant) and start it.
     * <p>
     * A real application would likely use an external server or one provided by a library or framework. Using the
     * internal Java SE one is only done for simplicity.
     */
    private void start() {
        Runtime.getRuntime().addShutdownHook(new Thread(this::stop));
        try {
            String hostname = PROPERTIES.get("hostname");
            int port = Integer.parseUnsignedInt(PROPERTIES.get("port"));
            httpServer = HttpsServer.create(new InetSocketAddress(hostname, port), 1);

            /* Configure TLS */
            HttpsConfigurator configurator = new HttpsConfigurator(getApplicationSslContext()) {
                @Override
                public void configure(HttpsParameters parameters) {
                    SSLContext sc = getSSLContext();
                    SSLParameters sslParameters = sc.getDefaultSSLParameters();

                    /* In this application we will accept unauthenticated connections to present friendly errors */
                    /* Also note that you should use only one of: setWantClientAuth() or setNeedClientAuth().
                     *  Otherwise you open yourself to errors and vulnerabilities. Refer to their Javadoc and code. */
                    sslParameters.setWantClientAuth(true);
                    parameters.setSSLParameters(sslParameters);
                }
            };
            httpServer.setHttpsConfigurator(configurator);


            httpServer.createContext("/", new HelloArrowhead());
            httpServer.start();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Stops the HelloArrowhead application.
     * <p>
     * Currently it only (has) to stop the HTTP server.
     * <p>
     * If further explanation is needed: The application keeps running, even if the "main" is not doing anything because
     * HttpServer uses an executor to keep one or multiple threads running to handle requests. We must ensure to tell
     * the HttpServer instance to stop these threads when the application is closing, otherwise they could stay alive
     * consuming resources (and, more importantly, they would remain bound to the given port, blocking it from further
     * use).
     * <p>
     * If you are using Java EE in your real application, you would have a dedicated server and therefore would not have
     * to worry about this (and as a general rule of thumb, you SHOULD NOT use threads in Java EE, even if you "find a
     * way to do it".
     */
    private void stop() {
        if (httpServer != null) {
            httpServer.stop(0);
        }
        System.out.println("Exiting. Bye.");
    }

    /**
     * Processes HTTP calls to the application.
     * Selects the necessary operation depending on the relative URI (in our case, the full path -- after the host).
     * <p>
     * This method is a handler for the HttpServer executor -- automatically called when an HTTP request comes in.
     * Furthermore, httpExchange gets passed to control the HTTP communication. As a minimum, it should be used to
     * send a response back. An auxiliary method is provided below for responding (httpRespond).
     * <p>
     * For each endpoint, the necessary processing is done and a corresponding answer is sent.
     * All the logic is delegated to the corresponding methods.
     * <p>
     * Description of each endpoint:
     * - /hello Responds with hello for authorised users.
     * - /setup Adds authorisation rule(s) and publishes for service discovery.
     * - /setdown Opposite of setup.
     *
     * @param httpExchange is used to control the HTTP communication (e.g. get headers, respond).
     * @throws IOException
     */
    @Override
    public void handle(HttpExchange httpExchange) throws IOException {
        String path = httpExchange.getRequestURI().getPath();
        switch (path) {
            case "/hello":
                String response = processHello(httpExchange);
                httpRespond(httpExchange, 200, response + "\n");
                break;
            case "/setup":
                setup();
                httpRespond(httpExchange, 200, "Service registered.\n");
                break;
            case "/setdown":
                setdown();
                httpRespond(httpExchange, 200, "Service unregistered.\n");
                break;
            default:
                httpRespond(httpExchange, 400, "Not a valid endpoint.\n");
        }
    }

    /**
     * Sends a response back to the HTTP caller.
     * <p>
     * This is an auxiliary method. Aside from the HttpExchange object used for handling the HTTP transaction, a code
     * and a message are passed in which will be the ones sent back to the caller.
     *
     * @param httpExchange the object used for handling the HTTP transaction.
     * @param code         the response code sent back to the user (e.g. 404).
     * @param message      the actual body of the response.
     * @throws IOException
     */
    private void httpRespond(HttpExchange httpExchange, int code, String message) throws IOException {
        httpExchange.sendResponseHeaders(code, message.length());
        OutputStream os = httpExchange.getResponseBody();
        os.write(message.getBytes());
        os.close();
    }

    /**
     * Processes a /hello request.
     * <p>
     * This is the main focal point on using Arrowhead in an actual application, the rest is boilerplate.
     * Currently, this showcases only the usage of the Authorisation Registry for determining whether or not a call is
     * allowed. This process involves three operations:
     * - Determine who is calling the service.
     * - Make a call to the Authorisation Registry requesting the authorisation status of the caller.
     * - Parse the XML response from the Authorisation Registry.
     * <p>
     * These operations remain the same regardless of the language or framework. This code showcases how to do it in
     * Java SE without external libraries and without using XML-POJO transformation for simplicity. Depending on your
     * requirements and resources, your actual implementation might be very different.
     *
     * @param httpExchange the object used for handling the HTTP transaction.
     * @return the response to be sent back to the caller.
     * @throws IOException
     */
    private String processHello(HttpExchange httpExchange) {
        /* Determine who is calling the service */
        HttpsExchange httpsExchange = (HttpsExchange) httpExchange;
        SSLSession sslSession = httpsExchange.getSSLSession();
        String name;
        try {
            name = sslSession.getPeerPrincipal().getName();
        } catch (SSLPeerUnverifiedException e) {
            System.out.println("Received an unauthenticated request.");
            return "You must provide a certificate to authenticate your identity.";
        }
        System.out.println("Received a request from: " + name);

        /* Ask if the given name is authorised to use a give service--THIS service */
        String authorisationControlEndpoint = PROPERTIES.get("authorisationControlUrl") + "/authorisation";
        String contentType = "application/xml";
        String message = AuthorisationMessages.AUTH_REQUEST_MSG.replaceAll(
                "<replaceForCn/>",
                name);
        String response = put(authorisationControlEndpoint, message, contentType);

        /* Parse the XML response from the Authorisation Registry */
        try {
            /* Parse using XPath, there are many other ways */
            DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
            DocumentBuilder documentBuilder = documentBuilderFactory.newDocumentBuilder();
            Document doc = documentBuilder.parse(new InputSource(new StringReader(response)));
            XPathFactory xPathFactory = XPathFactory.newInstance();
            XPath xPath = xPathFactory.newXPath();
            XPathExpression expression = xPath.compile("/authorisationResponse/authorised/text()");

            /* Respond correspondingly */
            String authorised = (String) expression.evaluate(doc, XPathConstants.STRING);
            if (authorised.equalsIgnoreCase("true")) {
                return "Hello";
            } else {
                return "Sorry, but you are unauthorized";
            }
        } catch (ParserConfigurationException | SAXException | XPathExpressionException e) {
            e.printStackTrace();
            return "Failed to parse the authorisation response";
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Processes a /setdown request.
     * <p>
     * SOMETHING LIKE THIS SHOULD NOT BE AVAILABLE IN A REAL APPLICATION.
     * <p>
     * This is a method for adding a rule on the Authorisation Registry and publishing the service on the Service
     * Registry. As it is, this helps in demonstrating these two operations, but a real application would need to
     * consider the security implications of exposing such functionality.
     */
    private void setup() {
        /* Add authorisation rule(s) */
        String authAddMsg = AuthorisationMessages.AUTH_ADD_MSG.replaceAll(
                "<replaceForCn/>",
                "CN=" + PROPERTIES.get("authorizedCn"));
        String authEndpoint = PROPERTIES.get("authorisationUrl") + "/AuthorisationConfigurationService";
        String contentType = "text/xml";
        post(authEndpoint, authAddMsg, contentType);

        /* Publish service */
        String serviceDiscoveryEndpoint = PROPERTIES.get("serviceDiscoveryUrl") + "/publish";
        contentType = "application/xml";
        post(serviceDiscoveryEndpoint, SimpleServiceDiscoveryMessages.SERVICE_PUBLISH_MSG, contentType);
    }

    /**
     * Processes a /setdown request.
     * <p>
     * SOMETHING LIKE THIS SHOULD NOT BE AVAILABLE IN A REAL APPLICATION.
     * <p>
     * This is a method for removing a rule from the Authorisation Registry and un-publishing the service from the
     * Service Registry. As it is, this helps in demonstrating these two operations, but a real application would need
     * to consider the security implications of exposing such functionality.
     */
    private void setdown() {
        /* Remove authorisation rule(s) */
        String authRemoveMsg = AuthorisationMessages.AUTH_REMOVE_MSG.replaceAll(
                "<replaceForCn/>",
                "CN=" + PROPERTIES.get("authorizedCn"));
        String authEndpoint = PROPERTIES.get("authorisationUrl") + "/AuthorisationConfigurationService";
        String contentType = "text/xml";
        post(authEndpoint, authRemoveMsg, contentType);

        /* Unpublish service */
        String serviceDiscoveryEndpoint = PROPERTIES.get("serviceDiscoveryUrl") + "/unpublish";
        contentType = "application/xml";
        post(serviceDiscoveryEndpoint, SimpleServiceDiscoveryMessages.SERVICE_UNPUBLISH_MSG, contentType);
    }

    /**
     * Wraps a call for a POST HTTTP request. See request().
     *
     * @param url         the URL on which to perform a POST.
     * @param body        the body or payload to POST.
     * @param contentType the value of the "content-type" header.
     * @return The response we got back from the server.
     */
    private String post(String url, String body, String contentType) {
        return request(url, body, contentType, "POST");
    }

    /**
     * Wraps a call for a PUT HTTTP request. See request().
     *
     * @param url         the URL on which to perform a PUT.
     * @param body        the body or payload to PUT.
     * @param contentType the value of the "content-type" header.
     * @return the response we got back from the server.
     */
    private String put(String url, String body, String contentType) {
        return request(url, body, contentType, "PUT");
    }

    /**
     * A wrapper for making either HTTP or HTTPS requests.
     * <p>
     * Arrowhead uses HTTP for some endpoints and HTTPS for others. For the HTTPS endpoints it is always necessary to
     * send a client certificate which has to be generated outside the application and, either, registered on the server
     * or signed by a CA registered on the server. For docker-ahf the preferred method is the latter, as a CA is
     * pre-registered in the server of the core services and its keys for signing new certificates are provided for
     * development. Furthermore, the server will send its own certificate, which we must also compare against our own
     * trust store; again, for docker-ahf, the preferred method is to use the provided files (in this case,
     * cacerts.jks).
     * <p>
     * To showcase what the operations specific to HTTPS are, the handlers for HTTP and HTTPS have been separated.
     * This method just calls the corresponding one depending on the protocol.
     *
     * @param url         URL on which to perform the request.
     * @param body        the body or payload to be sent.
     * @param contentType the value of the "content-type" header.
     * @param httpMethod  the HTTP method to perform (e.g. GET, which is what a browser most often does).
     * @return the response we got back from the server.
     */
    private String request(String url, String body, String contentType, String httpMethod) {
        URL endpoint;
        try {
            endpoint = new URL(url);
            String protocol = endpoint.getProtocol();

            if (protocol.equalsIgnoreCase("http")) {
                return requestHttp(endpoint, body, contentType, httpMethod);
            } else if (protocol.equalsIgnoreCase("https")) {
                return requestHttps(endpoint, body, contentType, httpMethod);
            } else {
                throw new RuntimeException("Protocol '" + protocol + "' not allowed.");
            }
        } catch (MalformedURLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Makes a request on an HTTP endpoint.
     * <p>
     * This method is for performing HTTP calls on a given endpoint using only Java SE. You will likely use a library
     * to reduce boilerplate, increase reliability and/or increase security.
     *
     * @param endpoint    URL on which to perform the request.
     * @param body        the body or payload to be sent.
     * @param contentType the value of the "content-type" header.
     * @param httpMethod  the HTTP method to perform (e.g. GET, which is what a browser most often does).
     * @return the response we got back from the server.
     */
    private String requestHttp(URL endpoint, String body, String contentType, String httpMethod) {
        try {
            HttpURLConnection connection;
            connection = (HttpURLConnection) endpoint.openConnection();

            connection.setRequestMethod(httpMethod);
            connection.setRequestProperty("Content-Type", contentType);
            connection.setDoOutput(true);

            DataOutputStream wr = new DataOutputStream(
                    connection.getOutputStream()
            );
            wr.writeBytes(body);
            wr.close();

            if (connection.getResponseCode() >= 400) {
                return "Failed with response code: " + connection.getResponseCode();
            }

            InputStream is = connection.getInputStream();
            BufferedReader rd = new BufferedReader(new InputStreamReader(is));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = rd.readLine()) != null) {
                response.append(line);
                response.append(System.lineSeparator());
            }
            rd.close();
            return response.toString();
        } catch (IOException e) {
            e.printStackTrace();
            return "Failed to perform the request, please refer to the error logs.";
        }
    }

    /**
     * Makes a request on an HTTPS endpoint.
     * <p>
     * This method is for performing HTTPS calls on a given endpoint using only Java SE. You will likely use a library
     * to reduce boilerplate, increase reliability and/or increase security.
     * <p>
     * As Arrowhead currently relies heavily on certificates for authentication, it is important to know how to make
     * HTTPS calls which use both a client certificate and which have access to a trust store (e.g. where CA
     * certificates are held) for validating the server certificate.
     * <p>
     * This is for pure Java SE using HttpsURLConnection. This will likely be different -but similar- if using a library
     * or framework. In general, what you need is a client key-pair (public and private) which might be provided
     * separately or in a key store, as well as a "trusted" certificate for validating the server's response; this
     * might be provided also in a key store, which in this scenario would be called a trust store (also often cacerts).
     *
     * @param endpoint    URL on which to perform the request.
     * @param body        the body or payload to be sent.
     * @param contentType the value of the "content-type" header.
     * @param httpMethod  the HTTP method to perform (e.g. GET, which is what a browser most often does).
     * @return the response we got back from the server.
     */
    private String requestHttps(URL endpoint, String body, String contentType, String httpMethod) {
        try {

            /* Open the connection and register the TLS context */
            HttpsURLConnection connection;
            connection = (HttpsURLConnection) endpoint.openConnection();
            SSLContext sc = getApplicationSslContext();
            connection.setSSLSocketFactory(sc.getSocketFactory());

            /* Perform the HTTPS operation -- everything below is the same as with HTTP */
            connection.setRequestMethod(httpMethod);
            connection.setRequestProperty("Content-Type", contentType);
            connection.setDoOutput(true);

            DataOutputStream wr = new DataOutputStream(
                    connection.getOutputStream()
            );
            wr.writeBytes(body);
            wr.close();

            if (connection.getResponseCode() >= 400) {
                return "Failed with response code: " + connection.getResponseCode();
            }

            InputStream is = connection.getInputStream();
            BufferedReader rd = new BufferedReader(new InputStreamReader(is));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = rd.readLine()) != null) {
                response.append(line);
                response.append(System.lineSeparator());
            }
            rd.close();

            return response.toString();
        } catch (IOException e) {
            e.printStackTrace();
            return "Failed to perform the request, please refer to the error logs.";
        }
    }

    /**
     * Returns and, if necessary, configures the SSL context to use by the application.
     * <p>
     * This is a lazy initialization of the SSL context. It is done only once, when the method is first called. Any
     * further calls, will return the previously initialized SSL context.
     * <p>
     * The initialization involves opening the files containing the trust store for the CA and the key store for the
     * client certificate.
     * <p>
     * Please note that because of a potential bug in the Java source code, the trust store should be a JKS file which
     * contains ONLY the public certificate of the ONE CA we will use. Whether or not this is true, it should not affect
     * you because you should use a dedicated library, framework or software for the HTTPS server.
     *
     * @return the single SSLContext instance.
     */
    private SSLContext getApplicationSslContext() {
        if (sslContext != null) return sslContext;

        SSLContext sc = null;
        try {
            /* Open the client key store */
            KeyStore clientKeystore = KeyStore.getInstance("JKS");
            char[] ksPassphrase = PROPERTIES.get("keystorePassphrase").toCharArray();

            FileInputStream fis = new FileInputStream(PROPERTIES.get("keystoreLocation"));
            clientKeystore.load(fis, ksPassphrase);

            KeyManagerFactory kmFactory = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
            kmFactory.init(clientKeystore, ksPassphrase);
            fis.close();

            /* Open the trust store */
            KeyStore caKeystore = KeyStore.getInstance("JKS");

            fis = new FileInputStream(PROPERTIES.get("cacertsLocation"));
            caKeystore.load(fis, ksPassphrase);

            TrustManagerFactory trustManagerFactory =
                    TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
            trustManagerFactory.init(caKeystore);
            fis.close();

            /* Configure TLS parameters to use the given certificates */
            sc = SSLContext.getInstance("TLS");
            sc.init(kmFactory.getKeyManagers(), trustManagerFactory.getTrustManagers(), null);
        } catch (KeyStoreException | IOException | CertificateException | UnrecoverableKeyException |
                KeyManagementException | NoSuchAlgorithmException e) {
            System.err.println("Failed to configure the SSL/TLS context." +
                    "Review the file types, locations and passphrases.");
            e.printStackTrace();
            System.exit(551);
        }
        return sc;
    }
}



