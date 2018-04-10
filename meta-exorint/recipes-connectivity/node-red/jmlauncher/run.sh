#!/bin/sh

cd $(dirname $0)

cd deploy

PGID=` cat /proc/$$/stat | awk '{print $5}'`
echo $PGID > /var/run/hmi-node-red.pid # save pid for termination
(
    # export required variables (not availables if started by jmlauncher daemon)
    export USER=`busybox whoami`
    export HOME=`eval echo ~$USER`
    echo "Starting HMI as user \"$USER\" with home \"$HOME\""
    ./start.sh $@;
    dbus-send --print-reply --system --dest=com.exor.JMLauncher '/' com.exor.JMLauncher.appFinished string:"node-red"
    PID="$(cat /var/run/hmi-node-red.pid)"
    rm /var/run/hmi-node-red.pid
    pkill -TERM  -s $PID;       # kill all child spawned processes if any
) &

# Wait Node-Red is started
sleep 30

if ( pgrep node-red > /dev/null ); then
    # starts debugging resources (print a report every 60 minutes and check ram usage every 60 seconds)
    dbus-send --print-reply --system --dest=com.exor.EPAD /SysStat com.exor.EPAD.SysStat.monitorSystemResources int32:60 int32:60

    dbus-send --print-reply --system --dest=com.exor.JMLauncher '/' com.exor.JMLauncher.appLoaded string:"node-red"
fi
