#!/bin/sh -e
#
# Hardware reset Redpine RS9113 interface
#
. /etc/default/wifi_gpio
#Wifi reset Wu16
if [ "$WIFI_GPIO" != "" ]
then
    if [ ! -d /sys/class/gpio/gpio$WIFI_GPIO/ ]
    then
        echo $WIFI_GPIO > /sys/class/gpio/export
    fi;
    echo out > /sys/class/gpio/gpio$WIFI_GPIO/direction
    echo 0 > /sys/class/gpio/gpio$WIFI_GPIO/value
fi;
