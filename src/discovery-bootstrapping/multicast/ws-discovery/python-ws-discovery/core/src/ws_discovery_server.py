#!/usr/bin/env python
"""
Server for Service Discovery bootstrapping using github.com/andreikop/python-ws-discovery.

Version 17.12.5.0

TODO: Consider another option for recognizing bootstrapping.
"""

import argparse
import signal
import time
import sys
from WSDiscovery import WSDiscovery, QName, Scope

signal.signal(signal.SIGINT, signal.default_int_handler)
try:
    wsd = WSDiscovery()
    wsd.start()

    parser = argparse.ArgumentParser()
    parser.add_argument("--ns", default="http://arrowhead.eu")
    parser.add_argument("--type", default="ArrowheadServiceDiscovery")
    parser.add_argument("--uri")
    parser.add_argument("--ip")
    parser.add_argument("--publishInterval", type=float, default=1.0)
    args = parser.parse_args()

    service_type = QName(args.ns, args.type)
    scope = Scope(args.ns)
    while True:
        wsd.publishService(types=[service_type], scopes=[scope], xAddrs=[args.uri, args.ip])
        time.sleep(args.publishInterval)
except KeyboardInterrupt:
    print("Stopping the bootstrapper...")
finally:
    wsd.stop()
