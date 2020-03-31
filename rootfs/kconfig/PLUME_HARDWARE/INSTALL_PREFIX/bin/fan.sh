#!/bin/sh
#
# Initializes and sets the fan to a given number of RPMs.
#

RPMS="$1"
GPIO_NO=45

[ ! -e /sys/class/gpio/gpio${GPIO_NO}/direction ] && {
    echo ${GPIO_NO}    > /sys/class/gpio/export
    echo out           > /sys/class/gpio/gpio${GPIO_NO}/direction
}

echo "Setting fan to ${RPMS} RPMs"
echo ${RPMS} > /sys/class/hwmon/hwmon0/rpm
echo 1       > /sys/class/gpio/gpio${GPIO_NO}/value
