/**
 * @file Creates an AHF-enabled service. Performs authorisation and service registration.
 * @version 17.11.2.0
 *
 * Currently it requires you to manually copy hello-ahf.p12 and dockerca.pem before running.
 * TODO: Document further.
 * TODO: Explore why CA is not needed in serverOptions. (Maybe it inherits CA from pfx. Otherwise vulnerability.)
 */

const parseXml = require('xml2js').parseString;
const express = require('express');
const request = require('request');
const https = require('https');
const fs = require('fs');

const servicePublishMsg = fs.readFileSync('./messages/service-publish.xml', 'utf8');
const serviceUnpublishMsg = fs.readFileSync('./messages/service-unpublish.xml', 'utf8');
const authRequestMsg = fs.readFileSync('./messages/authorization-request.xml', 'utf8');
const authAddMsg = fs.readFileSync('./messages/authorization-add.xml', 'utf8');
const authRemoveMsg = fs.readFileSync('./messages/authorization-remove.xml', 'utf8');

const port = 3111;
const host = '0.0.0.0';
const authorizedCn = 'client.docker.ahf';
const app = express();

var argv = require('minimist')(process.argv.slice(2));
var serviceDiscoveryUrl = argv['serviceDiscoveryUrl'];
var orchestrationUrl = argv['orchestrationUrl'];
var authorisationUrl = argv['authorisationUrl'];
var authorisationControlUrl = argv['authorisationControlUrl'];
var pfx = fs.readFileSync(argv['keystorePath']);
var passphrase = argv['keystorePassphrase'];
var ca = fs.readFileSync(argv['caPemPath']);

var serverOptions = {
    pfx: pfx,
    passphrase: passphrase,
    ca: ca,
    isServer: true,
    requestCert: true,
    rejectUnauthorized: true
};

var clientOptions = {
    pfx: pfx,
    passphrase: passphrase,
    ca: ca
};

function cleanup() {
    unpublish();
    process.exit();
}

function publish() {
    request.post(
        {
            url: serviceDiscoveryUrl + '/publish',
            headers: {
                'content-type': 'application/xml'
            },
            body: servicePublishMsg
        },
        function (error, response, body) {
            console.log(body);
        });
}

function unpublish() {
    request.post(
        {
            url: serviceDiscoveryUrl + '/unpublish',
            headers: {
                'content-type': 'application/xml'
            },
            body: serviceUnpublishMsg
        },
        function (error, response, body) {
            console.log(body);
        });
}

process.on('SIGINT', function () {
    cleanup();
});

process.on('SIGTERM', function () {
    cleanup();
});

server = https.createServer(serverOptions, app).listen(port, host);
console.log('HTTPS Server listening on %s:%s', host, port);

///----------------------------------------------------------------------------
/// Exposed endpoints
///----------------------------------------------------------------------------
app.get('/hello', function (req, res) {
    /* Who is calling the service? */
    var cn = req.socket.getPeerCertificate().subject.CN;

    /* Is the caller authorized to use this service? */
    request.put(
        {
            url: authorisationControlUrl + '/authorisation',
            agentOptions: clientOptions,
            headers: {
                'content-type': 'application/xml'
            },
            body: authRequestMsg.replace('<replaceForCn/>', 'CN=' + cn)
        },
        function (error, response, body) {
            parseXml(body, function (err, jsonResponse) {
                var isAuthorized = jsonResponse.authorisationResponse.authorised[0].toLowerCase().trim();
                var logMessage = 'Received a request from ' + cn + ', which is ';
                if (isAuthorized === 'true') {
                    res.send('Hello ' + cn + '\n');
                    console.log(logMessage + 'authorised.');
                } else {
                    res.send('Sorry, but you are unauthorized, ' + cn + '\n');
                    console.log(logMessage + 'unauthorised.');
                }
            });
        });
});


// This is to help during demonstrations.
// It would be a bad idea to expose something like this on a real system.
//
app.get('/allow', function (req, res) {
    var authorizedCn = req.get('AHF-Parameter-CName')
    request.post(
        {
            url: authorisationUrl + '/AuthorisationConfigurationService',
            agentOptions: clientOptions,
            headers: {
                'content-type': 'text/xml'
            },
            body: authAddMsg.replace('<replaceForCn/>', 'CN=' + authorizedCn)
        },
        function (error, response, body) {
            var answer = authorizedCn + ' is now authorised';
            res.send(answer + '\n');
            console.log(answer);
        });
});

// This is to help during demonstrations.
// It would be a bad idea to expose something like this on a real system.
//
app.get('/deny', function (req, res) {
    var authorizedCn = req.get('AHF-Parameter-CName')
    request.post(
        {
            url: authorisationUrl + '/AuthorisationConfigurationService',
            agentOptions: clientOptions,
            headers: {
                'content-type': 'text/xml'
            },
            body: authRemoveMsg.replace('<replaceForCn/>', 'CN=' + authorizedCn)
        },
        function (error, response, body) {
            var answer = authorizedCn + ' is now unauthorised';
            res.send(answer + '\n');
            console.log(answer);
        });
});

// This is to help during demonstrations.
// It would be a bad idea to expose something like this on a real system.
//
app.get('/publish', function (req, res) {
    publish();
    res.send("Published\n");
});


// This is to help during demonstrations.
// It would be a bad idea to expose something like this on a real system.
//
app.get('/unpublish', function (req, res) {
    unpublish();
    res.send("Unpublished\n");
});

