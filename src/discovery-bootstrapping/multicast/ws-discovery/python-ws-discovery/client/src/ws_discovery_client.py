#!/usr/bin/env python
"""
Client for Service Discovery bootstrapping using github.com/andreikop/python-ws-discovery.

Version 17.12.5.0

TODO: Consider multiple answers.
TODO: Consider another option for recognizing bootstrapping.
"""

import argparse
import signal
import time
import sys
from WSDiscovery import WSDiscovery, QName, Scope

signal.signal(signal.SIGINT, signal.default_int_handler)
try:
    parser = argparse.ArgumentParser()
    parser.add_argument("--ns", default="http://arrowhead.eu")
    parser.add_argument("--type", default="ArrowheadServiceDiscovery")
    parser.add_argument("--timeout", type=float, default=2.0)
    parser.add_argument("--interface")
    args = parser.parse_args()

    wsd = WSDiscovery()
    wsd.start()

    service_type = QName(args.ns, args.type)

    services = wsd.searchServices(types=[service_type], timeout=args.timeout)

    for service in services:
        print service.getXAddrs()[0] + " " + service.getXAddrs()[1]

except KeyboardInterrupt:
    print "Stopping the bootstrapper..."
finally:
    wsd.stop()

