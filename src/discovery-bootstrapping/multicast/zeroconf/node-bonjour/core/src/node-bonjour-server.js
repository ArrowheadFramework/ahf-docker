/**
 * @file Server for locating the Service Registry using the github.com/watson/bonjour package.
 * @version 17.12.5.1
 *
 * TODO: Consider another option for recognizing bootstrapping.
 */

var bonjour = require('bonjour')();

var argv = require('minimist')(process.argv.slice(2), {
    default: {
        name: "Service Discovery",
        type: "http",
        port: 8080,
        path: "/simpleservicediscovery",
        interface: "eth0"
    }});
var name = argv['name'];
var type = argv['type'];
var port = argv['port'];
var path = argv['path'];
var host = argv['host'];
var ip = argv['ip'];
var iface = argv['interface'];

/* If we are not given a host to publish, we get the current
 * IP address of the given interface. */
if (!host) {
    var networkInterfaces = require('os').networkInterfaces();
    host = networkInterfaces[iface][0]['address'];
}

/* If we are not given an IP address to publish, we get the current
 * one of the given interface. */
if (!host) {
    var networkInterfaces = require('os').networkInterfaces();
    host = networkInterfaces[iface][0]['address'];
}

bonjour.publish({
    name: name,
    type: type,
    port: port ,
    txt: {
        bootstrapper: "true",
        path: path,
        host: host,
        ip: ip
    }
});

process.on('SIGINT', function () {
    cleanup();
});

process.on('SIGTERM', function () {
    cleanup();
});

function cleanup() {
    console.log('Unpublishing all');
    bonjour.unpublishAll(function () {
        bonjour.destroy();
        process.exit();
    });
}