#!/bin/sh

while true;
do
    echo 1 > /dev/watchdog;
    sleep 5;
done
