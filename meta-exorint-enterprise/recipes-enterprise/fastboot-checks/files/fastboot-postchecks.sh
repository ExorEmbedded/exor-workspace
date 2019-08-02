#!/bin/bash

if [ "$1" != "start" ]
then
	exit 0;
fi

CONFIGOSPARTITION=/dev/mmcblk1p2
CONFIGOSTMPMNT=/mnt/configos
DATAPARTITION=/dev/mmcblk1p6
DATATMPMNT=/mnt/data

[ -e /etc/exorint.funcs ] && . /etc/exorint.funcs
carrier_ver=$( exorint_ver_carrier )

# Make sure data partition is mounted RW
if ( mount | grep $DATAPARTITION | grep -q -v rw, ); then
	[ "$ENABLE_ROOTFS_FSCK" = "yes" ] && exorint_extfsck $DATAPARTITION
	mount -o remount,rw $DATATMPMNT
	mount -o remount,rw /home
fi

mount -t ext4 -o ro $CONFIGOSPARTITION $CONFIGOSTMPMNT

if [ "$carrier_ver" == "WU16" ]; then
    if [ ! -e /etc/udev.tar ] || [ "$( cat /proc/version /proc/devices /proc/bus/input/devices )" != "$( cat /etc/udev/cache.data )" ]; then
        cd /
        rm -rf /etc/udev.tar /etc/udev/cache.data
        tar cf /etc/udev.tar dev
        sync
        cat /proc/version /proc/devices /proc/bus/input/devices > /etc/udev/cache.data
    fi
fi


# Blind device management
if [ "$(exorint_ver_type)" = "DEVICE" -o "$(exorint_ver_type)" = "ROUTER" ]; then
    sleep 1;
    # bootcounter reset - done by psplash for panels
    psplash-write "QUIT"
fi
