#!/bin/ash

set -e

chown -R exim: /var/spool/exim

if [ "${1:0:1}" = '-' ]; then
	exec exim "$@"
fi

if [ $1 = "exim" ]; then
    $@ &
    trap "kill $!" SIGINT SIGTERM
    wait
    exit $?
else
    set -- $@
fi
