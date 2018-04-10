#!/bin/bash
source /etc/exorint.funcs

if [ "$1" != "start" ]
then
	exit 0;
fi

echo "Starting Touchscreen check";

find_touch="false";
i=0;
while [ $i -lt 3 ] && [ "$find_touch" == "false" ]
do
	if [ ! -e /dev/input/touchscreen0 ]
	then
		echo "Touchscreen check, restart usb";
		echo usb1 > /sys/bus/usb/drivers/usb/unbind 2>/dev/null
		sleep 1;
		echo usb1 > /sys/bus/usb/drivers/usb/bind 2>/dev/null
		sleep 2;
	else
		find_touch="true"
	fi;
	i=$((i+1));
done

#641 UN65 eTOP7xx US03: Force restart if mounting of USB touchscreen fails
hda_e2_path="/sys/bus/i2c/devices/0-0056/eeprom"
exorint_in_mainos
so_type=$?
signature=$(hexdump $hda_e2_path -n2 | awk  '{print $2}' | head -n1)

if [ "$so_type" == 0 ] && [ "$signature" == "55aa" ]
then
	if [ "$find_touch" == "false" ] &&  [ ! -e /dev/input/touchscreen0 ]
	then
		reboot -f;
	fi
fi

