#!/bin/bash
DURATION=${DURATION:-300}
CLIENTS=${CLIENTS:-8}
THREADS=${THREADS:-2}
SCALE=100
USER=${PGUSER:-postgres}
export PGPASSWORD=password

if [[ $# -ne 2 ]]; then
    echo "$0 [host] [mode - init, run, rorun]"
    exit 2
fi

function init() {
	echo "recreating testdb..."
	psql -h $1 -U$USER -d postgres -c "drop database test"
	psql -h $1 -U$USER -d postgres -c "create database test"
	echo "initializing pgbench with scale $SCALE..."
	pgbench -i -s $SCALE -U$USER -h$1 test #&>/dev/null
}

function allrun() {
	echo "starting pgbench: pgbench -T $DURATION -U$USER -h $1 -c$CLIENTS -j$THREADS --protocol=prepared -n test"
	pgbench -T $DURATION -U$USER -h $1 -c$CLIENTS -j$THREADS --protocol=prepared -n test
}

function readonlyrun() {
	echo "starting pgbench: pgbench -T $DURATION -U$USER -h $1  -c$CLIENTS -j$THREADS --protocol=prepared -n -S test"
	pgbench -T $DURATION -U$USER -h $1 -c$CLIENTS -j$THREADS --protocol=prepared -n -S test
}

if [[ $2 == "init" ]]; then
    init $1
elif [[ $2 == "run" ]]; then
    allrun $1
elif [[ $2 == "rorun" ]]; then
    readonlyrun $1
fi

