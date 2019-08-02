#!/bin/bash
#JSxx
source /etc/exorint.funcs

if [ "$1" != "start" ]
then
	exit 0;
fi

log()
{
    echo "Touchscreen init check $@" > /dev/kmsg 
}

echo "Starting Touchscreen check";

find_touch="false";
if [ -e /dev/input/touchscreen0 ]
then
    find_touch="true"
    log "/dev/input/touchscreen0 found!";
fi;
bootcount=$( hexdump /sys/bus/i2c/devices/0-0068/nvram -C | head -n1 | awk  '{ print $3 }' )

exorint_in_mainos
so_type=$?

if [ "$so_type" == 0 ] && [ "$bootcount" -le "2" ]
then
    if [ "$find_touch" == "false" ] &&  [ ! -e /dev/input/touchscreen0 ]
    then
        /etc/init.d/syslog start
        sleep 2;
        log "/dev/input/touchscreen0 not found! -- REBOOT";
        sync;
        reboot -f;
    fi
fi

