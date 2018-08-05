#!/bin/sh
set -e
. util.sh

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
override_property_if_given   "server_address"               "$SERVER_ADDRESS"
override_property_if_given   "gateway_address"              "$GATEWAY_ADDRESS"
override_property_if_given   "db_user"                      "$DB_USER"
override_property_if_given   "db_password"                  "$DB_PASSWORD"
override_property_if_given   "db_address"                   "$DB_ADDRESS"
override_property_if_given   "cloud_keystore"               "$CLOUD_KEYSTORE"
override_property_if_given   "cloud_keystore_pass"          "$CLOUD_KEYSTORE_PASS"
override_property_if_given   "cloud_keypass"                "$CLOUD_KEYPASS"
override_property_if_given   "auth_keystore"                "$AUTH_KEYSTORE"
override_property_if_given   "auth_keystorepass"            "$AUTH_KEYSTOREPASS"
override_property_if_given   "event_publishing_delay"       "$EVENT_PUBLISHING_DELAY"
override_property_if_given   "remove_old_filters"           "$REMOVE_OLD_FILTERS"
override_property_if_given   "filter_check_interval"        "$FILTER_CHECK_INTERVAL"
override_property_if_given   "gateway_socket_timeout"       "$GATEWAY_SOCKET_TIMEOUT"
override_property_if_given   "use_gateway"                  "$USE_GATEWAY"
override_property_if_given   "master_arrowhead_cert"        "$MASTER_ARROWHEAD_CERT"
override_property_if_given   "min_port"                     "$MIN_PORT"
override_property_if_given   "max_port"                     "$MAX_PORT"
override_property_if_given   "gateway_keystore"             "$GATEWAY_KEYSTORE"
override_property_if_given   "gateway_keystore_pass"        "$GATEWAY_KEYSTORE_PASS"
override_property_if_given   "ping_scheduled"               "$PING_SCHEDULED"
override_property_if_given   "ping_timeout"                 "$PING_TIMEOUT"
override_property_if_given   "ping_interval"                "$PING_INTERVAL"
override_property_if_given   "ttl_scheduled"                "$TTL_SCHEDULED"
override_property_if_given   "ttl_interval"                 "$TTL_INTERVAL"

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
    /usr/bin/mysqld_safe --user=mysql --datadir='/var/lib/mysql' & > mysql_run.log
    wait_for_mysql "$DB_USER" "$DB_PASSWORD"
    java -jar arrowhead_core-4.0-lw.jar -daemon &
else
    exec "$@" &
fi

pid=$!
wait "${pid}"
