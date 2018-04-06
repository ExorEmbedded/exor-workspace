#!/bin/sh
### BEGIN INIT INFO
# Provides:          module-init-tools
# Required-Start:    
# Required-Stop:     
# Should-Start:      checkroot
# Should-stop:
# Default-Start:     S
# Default-Stop:
# Short-Description: Process /etc/modules.
# Description:       Load the modules listed in /etc/modules.
### END INIT INFO

BLACK_LIST_FILE="/etc/modprobe.d/blacklist.conf"
#Check for sukonetK custom kernel module
if [ ! -e $BLACK_LIST_FILE ]
then
    touch $BLACK_LIST_FILE
fi;

if [ -e /mnt/data/hmi/qthmi/deploy/SCNK_custom_serial_drv ]
then
    res=$(grep "imx$" $BLACK_LIST_FILE)
    if [ "$?" != "0" ] && [ -e /lib/modules/`uname -r`/kernel/drivers/tty/serial/imx_exor_uart.ko ]
    then
        echo "blacklist imx" > $BLACK_LIST_FILE
    fi;
else
    res=$(grep "imx_exor_uart$" $BLACK_LIST_FILE)
    if [ "$?" != "0" ]
    then
        echo "blacklist imx_exor_uart" > $BLACK_LIST_FILE
    fi;
fi
sync

LOAD_MODULE=modprobe
[ -f /proc/modules ] || exit 0
[ -f /etc/modules ] || [ -d /etc/modules-load.d ] || exit 0
[ -e /sbin/modprobe ] || LOAD_MODULE=insmod

if [ ! -f /lib/modules/`uname -r`/modules.dep ]; then
	[ "$VERBOSE" != no ] && echo "Calculating module dependencies ..."
	depmod -Ae
fi

loaded_modules=" "

process_file() {
	file=$1

	(cat $file; echo; ) |
	while read module args
	do
		case "$module" in
			\#*|"") continue ;;
		esac
		[ -n "$(echo $loaded_modules | grep " $module ")" ] && continue
		[ "$VERBOSE" != no ] && echo -n "$module "
		eval "$LOAD_MODULE $module $args >/dev/null 2>&1"
		loaded_modules="${loaded_modules}${module} "
	done
}

[ "$VERBOSE" != no ] && echo -n "Loading modules: "
[ -f /etc/modules ] && process_file /etc/modules

[ -d /etc/modules-load.d ] || exit 0

for f in /etc/modules-load.d/*.conf; do
	process_file $f
done

[ "$VERBOSE" != no ] && echo

exit 0
