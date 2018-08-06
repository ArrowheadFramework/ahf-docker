package Messages;

public class AuthorisationMessages {
    public static String AUTH_ADD_MSG =
            "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"\n" +
                    "                  xmlns:aut=\"http://arrowhead.eu/authorisation\">\n" +
                    "    <soapenv:Header/>\n" +
                    "    <soapenv:Body>\n" +
                    "        <aut:addAuthorisationRule>\n" +
                    "            <name>hello-ahf</name>\n" +
                    "            <type>_hello-s-ws-https._tcp</type>\n" +
                    "            <distinguishedNameSuffix><replaceForCn/></distinguishedNameSuffix>\n" +
                    "        </aut:addAuthorisationRule>\n" +
                    "    </soapenv:Body>\n" +
                    "</soapenv:Envelope>";

    public static String AUTH_REMOVE_MSG =
            "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"\n" +
                    "                  xmlns:aut=\"http://arrowhead.eu/authorisation\">\n" +
                    "<soapenv:Header/>\n" +
                    "    <soapenv:Body>\n" +
                    "        <aut:removeAuthorisationRule>\n" +
                    "            <name>hello-ahf</name>\n" +
                    "            <type>_hello-s-ws-https._tcp</type>\n" +
                    "            <distinguishedNameSuffix><replaceForCn/></distinguishedNameSuffix>\n" +
                    "        </aut:removeAuthorisationRule>\n" +
                    "    </soapenv:Body>\n" +
                    "</soapenv:Envelope>";

    public static String AUTH_REQUEST_MSG =
            "<authorisationRequest> \n" +
            "    <serviceType>_hello-s-ws-https._tcp</serviceType>\n" +
            "    <serviceName>hello-ahf</serviceName>\n" +
            "    <distinguishedName><replaceForCn/></distinguishedName>\n" +
            "</authorisationRequest>";

}
