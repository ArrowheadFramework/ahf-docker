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

find . | grep swagger.json | xargs cat >> out.json

# The default operation is to print the resulting OpenAPI specification.
# But if "gendoc" is passed as an argument, we will output a tar.gz file
# containing Swagger-UI documentation.
if [ "${1}" = "gendoc" ]; then

    # Use our specification instead of one loaded from a URL
    sed -i -e "s/url:.*/spec: spec,/" doc/index.html
    sed -i -e "s:<script>:<script src='spec.js' type=\"text/javascript\"></script>\t\n<script>:" doc/index.html
    sed -e "1s/^/var spec = /" out.json > doc/spec.js

    # Hide the URL spec grabber. It looks like a search bar and has no instructions.
    sed -i -e "s/<style>/<style>\n\t.download-url-wrapper {display: none !important}/" doc/index.html

    # Package and output (meant to be piped into tar -xvz)
    tar -cf - doc/ | base64

else
    cat out.json
    echo ""
fi
