#!/bin/bash
# script to make the changes permanent (xinput is called with every Xorg start)
#
# can be used from Xsession.d
# script needs tee and sed (busybox variants are enough)


[ ! -d /tmp/.X11-unix ] && exit 1

PATH="/usr/bin:$PATH"

CALLINK="/etc/pointercal.xinput"
FACTORYMNT="/mnt/factory"
CALDIR="$FACTORYMNT/etc"
CALFILE="$CALDIR/pointercal.xinput"
LOGFILE="/var/log/xinput_calibrator.pointercal.log"

export DISPLAY=:0
ntouch=$(/usr/bin/xinput_calibrator --list | wc -l );

if [ "$ntouch" != "1" ]
then
	/bin/echo "Unique touch not found. ntouch = $ntouch";
	exit 1;
fi;


if [ -e $CALLINK ] ; then

    if grep replace $CALLINK ; then
        /bin/echo "Empty calibration file found, removing it"
        rm $CALLINK
    elif grep 'Evdev Axis Calibration' $CALLINK ; then
        /bin/echo "Old format calibration file found, removing it"
        rm $CALLINK
    else
        /bin/echo "Using calibration data stored in $CALLINK"
        . $CALLINK && exit 0
        if [ "$1" = "--restore" ]; then
            for i in 1 2 3 4 5; do
                sleep 1
                . $CALLINK && exit 0
            done 
        fi
    fi
fi

rotation=$(/bin/cat /etc/rotation);
touchname=$( /usr/bin/xinput_calibrator --list | awk -F\" '{print $2}' );
mount -o remount,rw $FACTORYMNT
mkdir -p $CALDIR

[ "$rotation" == "" ] && rotation=0;
case $rotation in
0)
	/bin/echo "Rotation 0 --> $rotation"
	echo -n "xinput set-int-prop \"$touchname\" \"Evdev Axis Inversion\" 8 0 0; "  > $CALFILE
	echo -n "xinput set-int-prop \"$touchname\" \"Evdev Axes Swap\" 8 0;"         >> $CALFILE
	;;
90)
	/bin/echo "Rotation 90 --> $rotation"
	echo -n "xinput set-int-prop \"$touchname\" \"Evdev Axis Inversion\" 8 1 0; "  > $CALFILE
	echo -n "xinput set-int-prop \"$touchname\" \"Evdev Axes Swap\" 8 1;"         >> $CALFILE
	;;
180)
	/bin/echo "Rotation 180 --> $rotation"
	echo -n "xinput set-int-prop \"$touchname\" \"Evdev Axis Inversion\" 8 1 1; "  > $CALFILE
	echo -n "xinput set-int-prop \"$touchname\" \"Evdev Axes Swap\" 8 0;"  	      >> $CALFILE
	;;
270)
	/bin/echo "Rotation 270 --> $rotation"
	echo -n "xinput set-int-prop \"$touchname\" \"Evdev Axis Inversion\" 8 0 1; "  > $CALFILE
	echo -n "xinput set-int-prop \"$touchname\" \"Evdev Axes Swap\" 8 1;"         >> $CALFILE
	;;
*)
	/bin/echo "Rotation error --> $rotation"
	exit 2;
	;;
esac

/bin/mount -o remount,ro $FACTORYMNT
/bin/ln -sf $CALFILE $CALLINK
/bin/echo "Calibration data stored in $CALFILE (log in $LOGFILE)"
for i in 1 2 3 4 5; do
    sleep 1
    . $CALLINK && exit 0
done 

exit 0;
