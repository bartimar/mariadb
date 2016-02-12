#!/bin/bash

echo "Running multiple entrypoints script..."

LOG=/var/log/all

touch $LOG

for a in /opt/*
do
    echo "running script $a"
    $a "$@" >> $LOG &
done

tail -f $LOG
