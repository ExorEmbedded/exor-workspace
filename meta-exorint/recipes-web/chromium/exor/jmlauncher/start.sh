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
GPU_FLAGS="--disable-gpu"
CMD_LINE=""

[ -e $CHROME_WINDOW_FLAG ] && exit 0
touch $CHROME_WINDOW_FLAG

CHROME_ARGS="--no-sandbox --disable-infobars --extensions-on-chrome-urls --disable-session-crashed-bubble \
        --no-first-run --kiosk --user-data-dir=$DATA_DIR --disk-cache-size=$DISK_CACHE_SIZE $GPU_FLAGS"

# Enable verbose log
# CHROME_ARGS="$CHROME_ARGS --enable-logging=stderr --v=1"

# ti-tsc device is not recognized as touchscreen. We need to force chromium to believe it is
titscdev=$( /usr/bin/xinput | grep ti-tsc | sed "s:.*id=\([0-9]*\).*:\1:" )
[ -n "$titscdev" ] && CHROME_ARGS="$CHROME_ARGS --touch-devices=$titscdev"

CHROME_ARGS_BG="$CHROME_ARGS --load-extension=$EXTENSION_DIR --no-startup-window"

# Chromium crash detection triggers every time the panel is powered off without properly closing the applciation. We have
# to clear out this state otherwise Chromium will refuse to load saved settings, probably considering safer this way.
[ -e $DATA_DIR/Default/Preferences ] && sed -i'' 's/"exit_type":"Crashed"/"exit_type":"Normal"/' $DATA_DIR/Default/Preferences

( pidof chrome &>/dev/null ) && deamonRunning=1

if [ ! -n "$deamonRunning" ]; then
	rm -rf $DATA_DIR/Singleton*
	rm -f "$EXTENSION_CACHE_LOCK"
fi

(
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

if [ -n "$deamonRunning" ]; then
	echo Deamon already running
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
