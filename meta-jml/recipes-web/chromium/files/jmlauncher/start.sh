#!/bin/sh

cd $(dirname $0)
SCRIPTDIR=$(pwd)
echo $SCRIPTDIR

export DISPLAY=:0
. $HOME/.dbus/session-bus/*
export DBUS_SESSION_BUS_ADDRESS

export GTK_IM_MODULE_FILE=$SCRIPTDIR/gtk.immodules
export GTKIM_POS_IMPL=1

DATA_DIR="$SCRIPTDIR/.chromium/"
EXTENSION_DIR="$SCRIPTDIR/ext/"
EXTENSION_CACHE_LOCK="$DATA_DIR/Default/Local Extension Settings/pppblgnjgngbhkjehblmbfeklkbfamdm/LOCK"
EXTENSION_CMD_FILE="$EXTENSION_DIR/cmd_line.js"
CHROME_WINDOW_FLAG="/run/chrome-window"
DISK_CACHE_SIZE="52428800" # 50mb

CPU="$( cat /proc/cpuinfo | grep Hardware )"
if ( echo $CPU | grep -q "Freescale i.MX6" ); then
	GPU_FLAGS="--use-gl=egl --enable-zero-copy --disable-accelerated-2d-canvas --disable-es3-gl-context \
		--enable-gpu-compositing --enable-threaded-compositing"
else
	GPU_FLAGS="--disable-gpu"
fi

CMD_LINE=""

[ -e $CHROME_WINDOW_FLAG ] && exit 0
touch $CHROME_WINDOW_FLAG

CHROME_ARGS="--no-sandbox --extensions-on-chrome-urls --disable-session-crashed-bubble \
	--disable-infobars --overscroll-history-navigation=0 --no-first-run --kiosk \
        --user-data-dir=$DATA_DIR --disk-cache-size=$DISK_CACHE_SIZE $GPU_FLAGS"

# Uncomment to enable verbose log
# CHROME_ARGS="$CHROME_ARGS --enable-logging=stderr --v=1"

# Uncomment to enable remote debugging on port 9222
# CHROME_ARGS="$CHROME_ARGS --remote-debugging-port=9222"

# Uncomment and set <IP> and <PORT> to enable proxy
# CHROME_ARGS="$CHROME_ARGS --proxy-bypass-list=127.0.0.1 --proxy-server=<IP>:<PORT>"

# ti-tsc device is not recognized as touchscreen. We need to force chromium to believe it is
titscdev=$( /usr/bin/xinput | grep ti-tsc | sed "s:.*id=\([0-9]*\).*:\1:" )
[ -n "$titscdev" ] && CHROME_ARGS="$CHROME_ARGS --touch-devices=$titscdev --touch-events"

CHROME_ARGS_BG="$CHROME_ARGS --load-extension=$EXTENSION_DIR --no-startup-window"

# Chromium crash detection triggers every time the panel is powered off without properly closing the applciation. We have
# to clear out this state otherwise Chromium will refuse to load saved settings, probably considering safer this way.
[ -e $DATA_DIR/Default/Preferences ] && sed -i'' 's/"exit_type":"Crashed"/"exit_type":"Normal"/' $DATA_DIR/Default/Preferences

( pidof chromium-bin &>/dev/null ) && daemonRunning=1

if [ ! -n "$daemonRunning" ]; then
	rm -rf $DATA_DIR/Singleton*
	rm -f "$EXTENSION_CACHE_LOCK"
fi

(
	export GTK_IM_MODULE_FILE=

	# Wait for daemon socket and extension cache dir to be created
	while [ ! -e $DATA_DIR/SingletonSocket -o ! -e "$EXTENSION_CACHE_LOCK" ]; do
		sleep 1
	done;

	sleep 1

	# Open a browser window
	LD_LIBRARY_PATH=$SCRIPTDIR/lib \
		./chromium-bin $CHROME_ARGS $@

	rm -f $CHROME_WINDOW_FLAG
) &

if [ -n "$daemonRunning" ]; then
	echo Daemon already running
	sleep 10
	exit 0
fi

# Pass command line to extension
[ -e settings ] && CMD_LINE="$( cat settings )"
CMD_LINE="$CMD_LINE $@"
echo 'var cmd_line = "'$CMD_LINE'";' > $EXTENSION_CMD_FILE
echo 'var inst_dir = "'$SCRIPTDIR'";' >> $EXTENSION_CMD_FILE

# Run the daemon fist to make sure the extension is loaded
LD_LIBRARY_PATH=$SCRIPTDIR/lib \
	./chromium-bin $CHROME_ARGS_BG

if [ $? -eq "137" -a ! -e $DATA_DIR/SingletonSocket ]; then
	sleep 2
	LD_LIBRARY_PATH=$SCRIPTDIR/lib \
		./chromium-bin $CHROME_ARGS_BG
fi

rm -f $CHROME_WINDOW_FLAG
