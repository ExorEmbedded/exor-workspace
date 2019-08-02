#!/bin/sh
HOSTAPD_CONF="/etc/hostapd.conf"
HOSTAPD_BIN="/usr/sbin/hostapd"
HOSTAPD_PIDFILE="/var/run/hostapd/$IFACE.pid"
HOSTAPD_OPTIONS="-B -P $HOSTAPD_PIDFILE -i $IFACE"

# run supplicant only on enabled wireless devices
iw dev | grep -q "Interface $IFACE" || exit 0

if [ "$MODE" = "start" ] ; then

	if [ "$MANUAL" = "" ] ; then

		# make sure interface is autostarted
		sys_params network/wifi/autostartInterfaces 2>/dev/null | grep -q "$IFACE" || exit 0

		# AP: apply volatile mode if defined, otherwise persistent
		VMODE=$(sys_params -l -V services/wifi/interfaces/$IFACE/mode)
		if [ -n "$VMODE" ]; then
			[ "$VMODE" = "AP" ] || exit 0
		else
			[ "$(sys_params -l network/wifi/interfaces/[name=$IFACE]/mode)" = "AP" ] || exit 0
		fi
	fi

	if [ -n "$HOSTAPD_CONF" ]; then
		
		start-stop-daemon --start --quiet \
			--startas $HOSTAPD_BIN --pidfile $HOSTAPD_PIDFILE \
			--  $HOSTAPD_OPTIONS $HOSTAPD_CONF 
	fi

elif [ "$MODE" = "stop" ]; then

	if [ -f "$HOSTAPD_PIDFILE" ]; then
		
		start-stop-daemon --stop --quiet --pidfile	$HOSTAPD_PIDFILE
			
		if [ -f "$HOSTAPD_PIDFILE" ]; then
			rm -f $HOSTAPD_PIDFILE
		fi
	fi

fi

exit 0
