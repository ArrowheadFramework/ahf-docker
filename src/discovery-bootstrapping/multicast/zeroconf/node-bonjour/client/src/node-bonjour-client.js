/**
 * @file Client for locating the Service Registry using the github.com/watson/bonjour package.
 * @version 17.12.5.1
 *
 * TODO: Consider multiple protocols.
 * TODO: Consider another option for recognizing bootstrapping.
 */

var bonjour = require('bonjour')();


/* Look for HTTP options */
bonjour.find({ type:'http' }, matchHandler);

/* Look for HTTPS options */
bonjour.find({ type:'https' }, matchHandler);

function matchHandler(service) {
    if ('bootstrapper' in service.txt) {
        var host = 'host' in service.txt ? service.txt['host'] : service.addresses[0];
        var ip = 'ip' in service.txt ? service.txt['ip'] : service.addresses[0];
        var uri = '';
        if (service.type) {
            uri += service.type + '://';
        }
        uri += host;
        if (service.port) {
            uri += ':' + service.port;
        }
        if ('path' in service.txt) {
            uri += service.txt['path'];
        }
        console.log(uri + ' ' + ip);
    }
}

process.on('SIGINT', function () {
    cleanup();
});

process.on('SIGTERM', function () {
    cleanup();
});

function cleanup() {
    process.exit();
}