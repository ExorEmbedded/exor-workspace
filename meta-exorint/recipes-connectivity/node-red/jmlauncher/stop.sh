#!/bin/sh

cd $(dirname $0)

cd deploy
# kill the entire process group
PID="$(cat /var/run/hmi-node-red.pid)"
rm /var/run/hmi-node-red.pid

for p in `pgrep chrome` ; do
	if [ "`cat /proc/$p/stat | awk '{print $5}'`" = "$PID" ] ; then
		for p in `pgrep -s "$PID"` ; do
			echo "Node-Red app: going to kill session group process $p : `cat /proc/$p/cmdline`"
		done
		pkill -TERM -s $PID
		break;
	fi
done



