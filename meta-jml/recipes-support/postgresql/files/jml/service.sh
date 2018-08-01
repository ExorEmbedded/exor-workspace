#!/bin/sh
#
# postgresql	This is the init script for starting up the PostgreSQL
#		server.
#
# chkconfig: - 64 36
# description: PostgreSQL database server.
# processname: postmaster
# pidfile: /var/run/postmaster.PORT.pid

# This script is slightly unusual in that the name of the daemon (postmaster)
# is not the same as the name of the subsystem (postgresql)

# PGVERSION is the full package version, e.g., 8.4.0
# Note: the specfile inserts the correct value during package build
PGVERSION=9.4.15
# PGMAJORVERSION is major version, e.g., 8.4 (this should match PG_VERSION)
PGMAJORVERSION=`echo "$PGVERSION" | sed 's/^\([0-9]*\.[0-9]*\).*$/\1/'`

# Find the name of the script
cd $( dirname $0 )
SCRIPT_DIR="$( pwd )"

export PATH="$SCRIPT_DIR/bin:/sbin:/bin:/usr/sbin:/usr/bin"
export LD_LIBRARY_PATH="$SCRIPT_DIR/lib"

NAME=`basename $0`
if [ ${NAME:0:1} = "S" -o ${NAME:0:1} = "K" ]
then
	NAME=${NAME:3}
fi

# For SELinux we need to use 'runuser' not 'su'
if [ -x /sbin/runuser ]
then
    SU=runuser
else
    SU=su
fi

# Set defaults for configuration variables
export PGENGINE="$SCRIPT_DIR/bin"
export PGPORT=5432
export PGDATA="$SCRIPT_DIR/data"
export PGLOG=/var/log/pgstartup.log
# Value to set as postmaster process's oom_adj
PG_OOM_ADJ=-17

lockfile="/var/lock/subsys/${NAME}"
pidfile="/var/run/postmaster.${PGPORT}.pid"

script_result=0

start(){
	[ -x "$PGENGINE/postmaster" ] || exit 5

	PSQL_START=$"Starting ${NAME} service: "

	if ( ! id postgres ); then
		adduser --system --home $SCRIPT_DIR/lib/postgresql --shell /bin/bash --uid 28 postgres
		groupadd -g 28 postgres
		adduser postgres postgres
		adduser postgres data
		sync
	fi

	# Make sure startup-time log file is valid
	if [ ! -e "$PGLOG" -a ! -h "$PGLOG" ]
	then
		touch "$PGLOG" || exit 4
		chown postgres:postgres "$PGLOG"
		chmod go-rwx "$PGLOG"
		[ -x /sbin/restorecon ] && /sbin/restorecon "$PGLOG"
	fi

	if [ ! -e "/etc/logrotate.d/postgresql" ]; then
		cat << EOF > /etc/logrotate.d/postgresql
$PGLOG {
    size 50k
}
EOF
		sync
	fi

	# Check for the PGDATA structure
	if [ ! -f "$PGDATA/PG_VERSION" ] || [ ! -d "$PGDATA/base" ] || [ ! -f "$SCRIPT_DIR/.dbInit" ] ; then
		rm -rf $SCRIPT_DIR/.dbInit $PGDATA; sync
		postgresql-setup initdb || exit 1
		sync
		touch $SCRIPT_DIR/.dbInit; sync
	fi

	# Check version of existing PGDATA
	if [ x`cat "$PGDATA/PG_VERSION"` != x"$PGMAJORVERSION" ]
	then
		SYSDOCDIR="(Your System's documentation directory)"
		if [ -d "/usr/doc/postgresql-$PGVERSION" ]
		then
			SYSDOCDIR=/usr/doc
		fi
		if [ -d "/usr/share/doc/postgresql-$PGVERSION" ]
		then
			SYSDOCDIR=/usr/share/doc
		fi
		if [ -d "/usr/doc/packages/postgresql-$PGVERSION" ]
		then
			SYSDOCDIR=/usr/doc/packages
		fi
		if [ -d "/usr/share/doc/packages/postgresql-$PGVERSION" ]
		then
			SYSDOCDIR=/usr/share/doc/packages
		fi
		echo
		echo $"An old version of the database format was found."
		echo $"You need to upgrade the data format before using PostgreSQL."
		echo $"See $SYSDOCDIR/postgresql-$PGVERSION/README.rpm-dist for more information."
		exit 1
	fi

	echo -n "$PSQL_START"
	test x"$PG_OOM_ADJ" != x && echo "$PG_OOM_ADJ" > /proc/self/oom_score_adj

	(
		sleep 3
		pid=`head -n 1 "$PGDATA/postmaster.pid" 2>/dev/null`
		if [ "x$pid" != x ]
		then
			echo -n " [ OK ]"
			touch "$lockfile"
			echo $pid > "$pidfile"
			echo
		fi
	)&

	$SU -l postgres -c "LD_LIBRARY_PATH='$LD_LIBRARY_PATH' \
		$PGENGINE/postmaster -p '$PGPORT' -D '$PGDATA' ${PGOPTS}" >> "$PGLOG" 2>&1 < /dev/null
}

stop(){
	echo -n $"Stopping ${NAME} service: "
	if [ -e "$lockfile" ]
	then
	    $SU -l postgres -c "LD_LIBRARY_PATH='$LD_LIBRARY_PATH' \
		$PGENGINE/pg_ctl stop -D '$PGDATA' -s -m fast" > /dev/null 2>&1 < /dev/null
	    ret=$?
	    if [ $ret -eq 0 ]
	    then
		echo -n " [ OK ] "
		rm -f "$pidfile"
		rm -f "$lockfile"
	    else
		echo -n " [FAILED] "
		script_result=1
	    fi
	else
	    # not running; per LSB standards this is "ok"
	    echo -n " [ OK ] "
	fi
	echo
}

restart(){
    stop
    start
}

condrestart(){
    [ -e "$lockfile" ] && restart || :
}

reload(){
    $SU -l postgres -c "LD_LIBRARY_PATH='$LD_LIBRARY_PATH' \
		$PGENGINE/pg_ctl reload -D '$PGDATA' -s" > /dev/null 2>&1 < /dev/null
}


# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  status)
	status postmaster
	script_result=$?
	;;
  restart)
	restart
	;;
  condrestart|try-restart)
	condrestart
	;;
  reload)
	reload
	;;
  force-reload)
	restart
	;;
  *)
	echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
	exit 2
esac

exit $script_result
