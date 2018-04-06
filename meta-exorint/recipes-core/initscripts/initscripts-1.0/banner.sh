#!/bin/sh
### BEGIN INIT INFO
# Provides: banner
# Required-Start:
# Required-Stop:
# Default-Start:     S
# Default-Stop:
### END INIT INFO

if [ ! -e /dev/tty ]; then
    /bin/mknod -m 0666 /dev/tty c 5 0
fi

