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

# Auxiliary functions
override_property_if_given() {
    prop="$1"
    val="$2"

    if [ -z "$prop" ]; then
        echo "override_property_if_given: A property name is required."
        exit 1
    fi

    if [ -n "$val" ]; then
        if grep -q "^$prop=.*$" "$PROPERTIES_FILE"; then
            sed -iE "/^$prop=.*/d" "$PROPERTIES_FILE"
        fi
        echo "$prop=$val" >> "$PROPERTIES_FILE"
    fi
}

ensure_trailing_newline() {
    # Add a trailing line break if missing in properties file
    if [ -n "$(tail -c 1 "$PROPERTIES_FILE")" ]; then
        echo "Warning: $PROPERTIES_FILE was missing a trailing line break."
        echo "" >> "$PROPERTIES_FILE"
    fi
}

# Use environment variables to override values in the app.properties file.
PROPERTIES_FILE='config/app.properties'
ensure_trailing_newline
override_property_if_given   "db_address"              "$DB_ADDRESS"
override_property_if_given   "keystore"                "$KEYSTORE"
override_property_if_given   "keystorepass"            "$KEYSTOREPASS"
override_property_if_given   "keypass"                 "$KEYPASS"
override_property_if_given   "truststore"              "$TRUSTSTORE"
override_property_if_given   "truststorepass"          "$TRUSTSTOREPASS"
override_property_if_given   "base_uri"                "$BASE_URI"
override_property_if_given   "base_uri_secured"        "$BASE_URI_SECURED"
override_property_if_given   "db_user"                 "$DB_USER"
override_property_if_given   "db_password"             "$DB_PASSWORD"
override_property_if_given   "db_address"              "$DB_ADDRESS"

# Use environment variables to override values in the log4j.properties file.
PROPERTIES_FILE='config/log4j.properties'
ensure_trailing_newline
override_property_if_given   "log4j.rootLogger"             "$LOG4J_ROOTLOGGER"
override_property_if_given   "log4j.appender.DB"            "$LOG4J_APPENDER_DB"
override_property_if_given   "log4j.appender.DB.driver"     "$LOG4J_APPENDER_DB_DRIVER"
override_property_if_given   "log4j.appender.DB.URL"        "$LOG4J_APPENDER_DB_URL"
override_property_if_given   "log4j.appender.DB.user"       "$LOG4J_APPENDER_DB_USER"
override_property_if_given   "log4j.appender.DB.password"   "$LOG4J_APPENDER_DB_PASSWORD"
override_property_if_given   "log4j.appender.DB.sql"        "$LOG4J_APPENDER_DB_SQL"
override_property_if_given   "log4j.appender.DB.layout"     "$LOG4J_APPENDER_DB_LAYOUT"
override_property_if_given   "log4j.logger.org.hibernate"   "$LOG4J_LOGGER_ORG_HIBERNATE"

if [ -z "$1" ]; then
    java -jar orchestrator-M2.jar -d -m both &
else
    exec "$@" &
fi

pid=$!
wait "${pid}"
