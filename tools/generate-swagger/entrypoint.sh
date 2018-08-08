#!/bin/sh
set -e

# Handle kill signals
cleanup_handler() {
    echo ""
    echo "Killing all the current processes."
    killall5 -2
    (sleep 10 && \
    echo "Had to forcibly kill remaining processes after 10 seconds." && \
    killall5 -9) &
}
trap cleanup_handler 1 2 3 15

find . | grep swagger.json | grep "$1" | xargs cat
echo ""
