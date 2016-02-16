#!/bin/bash
set -eo pipefail

echo "Running multiple entrypoints script... "
echo "rootPW: $MYSQL_ROOT_PASSWORD"

for a in /opt/*
do
    echo "running script $a"
    $a "$@"
done
