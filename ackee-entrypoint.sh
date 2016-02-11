#!/bin/bash

LOG=/var/log/all

touch $LOG

for a in /opt/*
do
    $a "$@" >> $LOG &
done

tail -f $LOG
