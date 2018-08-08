#!/bin/sh
set -e
. util.sh

# Defaults for environment variables
MYSQL_ROOT_PWD=${MYSQL_ROOT_PWD:-"mysql"}
MYSQL_USER=${MYSQL_USER:-"${DB_USER}"}
MYSQL_USER_PWD=${MYSQL_USER_PWD:-"${DB_PASSWORD}"}
MYSQL_USER_DB=${MYSQL_USER_DB:-"arrowhead"}

mysql_escape() {
    echo "$1" | sed 's/\(['"'"'\]\)/\\\1/g'
}

# Escape MySQL passwords, in case they contain restricted characters
MYSQL_ROOT_PWD=$(mysql_escape "${MYSQL_ROOT_PWD}")
MYSQL_USER_PWD=$(mysql_escape "${MYSQL_USER_PWD}")

if [ ! -d "/run/mysqld" ]; then
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
fi

if [ -d /var/lib/mysql/mysql ]; then
    echo "Using existing MySQL data directory."
else
    chown -R mysql:mysql /var/lib/mysql

    mysql_install_db --user=mysql > /mysql_install.log

    # Configure SQL initialization script
    sed -e "s/<MYSQL_ROOT_PWD>/${MYSQL_ROOT_PWD}/g" \
        -e "s/<MYSQL_USER>/${MYSQL_USER}/g" \
        -e "s/<MYSQL_USER_PWD>/${MYSQL_USER_PWD}/g" \
        -e "s/<MYSQL_USER_DB>/${MYSQL_USER_DB}/g" \
        db_init.sql.template > db_init.sql

    chown mysql:mysql ./*.sql

    # Start the database
    /usr/bin/mysqld_safe --user=mysql --datadir='/var/lib/mysql' & > mysql_run.log
    wait_for_mysql

    # Initialize the database
    /usr/bin/mysql < db_init.sql
    /usr/bin/mysql -u"${MYSQL_USER}" -p"${MYSQL_USER_PWD}" < 0050_create_arrowhead_database_empty.sql
    /usr/bin/mysql -u"${MYSQL_USER}" -p"${MYSQL_USER_PWD}" < 0050_create_log_db_empty.sql
    rm -f ./*.sql
fi
