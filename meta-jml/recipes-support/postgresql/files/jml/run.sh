#!/bin/sh

cd $(dirname $0)

cd deploy

PGID=` cat /proc/$$/stat | awk '{print $5}'`
echo $PGID > /var/run/postgresql.pid # save pid for termination
(
    # export required variables (not availables if started by jmlauncher daemon)
    export USER=`busybox whoami`
    export HOME=`eval echo ~$USER`
    echo "Starting HMI as user \"$USER\" with home \"$HOME\""
    ./service.sh start $@;
    dbus-send --print-reply --system --dest=com.exor.JMLauncher '/' com.exor.JMLauncher.appFinished string:"postgresql"
    PID="$(cat /var/run/postgresql.pid)"
    rm /var/run/postgresql.pid
    pkill -TERM  -s $PID;       # kill all child spawned processes if any
) &

# wait process is started
sleep 20

# Initializing the database could take a minute on a 300mhz device
[ ! -e .dbInit ] && sleep 60

if ( pgrep postmaster > /dev/null ); then
    # starts debugging resources (print a report every 60 minutes and check ram usage every 60 seconds)
    dbus-send --print-reply --system --dest=com.exor.EPAD /SysStat com.exor.EPAD.SysStat.monitorSystemResources int32:60 int32:60

    dbus-send --print-reply --system --dest=com.exor.JMLauncher '/' com.exor.JMLauncher.appLoaded string:"postgresql"
fi
