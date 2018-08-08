#!/bin/sh

wait_for_mysql() {
    if [ -n "${1}" ]; then
        userarg="-u${1}"
    fi

    if [ -n "${2}" ]; then
        passarg="-p${2}"
    fi

    retries_left=10
    while ! mysql -e "show databases;" ${userarg} ${passarg} > /dev/null 2>&1;
    do
        sleep 1
        retries_left=$((retries_left-1))
        if [ ! ${retries_left} ]; then
            echo "Failed to connect to the MySQL server after 10 seconds." >&2
            exit 1
        fi
    done
}
