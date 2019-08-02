PR := "${PR}.x10"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " file://exorint.rules file://exorint_sensors.rules"
SRC_URI_append_pa18 = " file://exorint_pa18.rules"

FB = '${@bb.utils.contains("MACHINE_FEATURES", "fastboot", "1", "0",d)}'
# As systemd also builds udev, skip this package if we're doing a systemd build.

python () {
    if bb.utils.contains ('MACHINE_FEATURES', 'fastboot', True, False, d):
        d.setVar('INITSCRIPT_PARAMS_udev', "start 10 5 .")
        d.setVar('INITSCRIPT_PARAMS_udev-cache', "start 75 5 .")
}


TTY_RULES = 'KERNEL=="${SERIAL_DEV}0", SUBSYSTEM=="tty", SYMLINK="com1"\n\
KERNEL=="${SERIAL_DEV}1", SUBSYSTEM=="tty", SYMLINK="com2"\n\
KERNEL=="${SERIAL_DEV}2", SUBSYSTEM=="tty", SYMLINK="com3"\n\
KERNEL=="${SERIAL_DEV}3", SUBSYSTEM=="tty", SYMLINK="com4"\n\
KERNEL=="${SERIAL_DEV}4", SUBSYSTEM=="tty", SYMLINK="com5"\n'

TTY_RULES_S = 'KERNEL=="${SERIAL_DEV}0", SUBSYSTEM=="tty", SYMLINK="com1 ttyS0"\n\
KERNEL=="${SERIAL_DEV}1", SUBSYSTEM=="tty", SYMLINK="com2 ttyS1"\n\
KERNEL=="${SERIAL_DEV}2", SUBSYSTEM=="tty", SYMLINK="com3 ttyS2"\n\
KERNEL=="${SERIAL_DEV}3", SUBSYSTEM=="tty", SYMLINK="com4 ttyS3"\n\
KERNEL=="${SERIAL_DEV}4", SUBSYSTEM=="tty", SYMLINK="com5 ttyS4"\n\
KERNEL=="ttyS0", SUBSYSTEM=="tty", PROGRAM="/bin/ln -sf ${SERIAL_DEV}0 /dev/ttyS0"\n\
KERNEL=="ttyS1", SUBSYSTEM=="tty", PROGRAM="/bin/ln -sf ${SERIAL_DEV}1 /dev/ttyS1"\n\
KERNEL=="ttyS2", SUBSYSTEM=="tty", PROGRAM="/bin/ln -sf ${SERIAL_DEV}2 /dev/ttyS2"\n\
KERNEL=="ttyS3", SUBSYSTEM=="tty", PROGRAM="/bin/ln -sf ${SERIAL_DEV}3 /dev/ttyS3"\n\
KERNEL=="ttyS4", SUBSYSTEM=="tty", PROGRAM="/bin/ln -sf ${SERIAL_DEV}4 /dev/ttyS4"\n'


do_install_append () {

    # Remove config files which have migrated to base
    rm ${D}${sysconfdir}/udev/udev.conf

    install -m 0644 ${WORKDIR}/exorint.rules ${D}${sysconfdir}/udev/rules.d/exorint.rules
    install -m 0644 ${WORKDIR}/exorint_sensors.rules ${D}${sysconfdir}/udev/rules.d/exorint_sensors.rules
        
    if [ -n '${SERIAL_DEV}' ]; then
        if [ '${SERIAL_DEV}' = "ttyS" ]; then
            printf '${TTY_RULES}\n' >> ${D}${sysconfdir}/udev/rules.d/exorint.rules
        else
            printf '${TTY_RULES_S}\n' >> ${D}${sysconfdir}/udev/rules.d/exorint.rules
        fi
    fi
}

do_install_append_na16 () {
    sed -i '/KERNEL=="ttyS[1-4]"/s/^/#/' ${D}${sysconfdir}/udev/rules.d/exorint.rules
    sed -i '/KERNEL=="ttyO[1-4]"/s/^/#/' ${D}${sysconfdir}/udev/rules.d/exorint.rules
    echo "#Custom Na16 rule to use ttyO2 as com2" >> ${D}${sysconfdir}/udev/rules.d/exorint.rules
    printf 'KERNEL=="ttyO2", SUBSYSTEM=="tty", SYMLINK="com2 ttyS1"\n' >> ${D}${sysconfdir}/udev/rules.d/exorint.rules
    printf 'KERNEL=="ttyS1", SUBSYSTEM=="tty", PROGRAM="/bin/ln -sf ${SERIAL_DEV}2 /dev/ttyS1"\n' >> ${D}${sysconfdir}/udev/rules.d/exorint.rules
}

do_install_append_us01-wu16 () {
    sed -i '/KERNEL=="ttyS[1-4]"/s/^/#/' ${D}${sysconfdir}/udev/rules.d/exorint.rules
    sed -i '/KERNEL=="ttyO[1-4]"/s/^/#/' ${D}${sysconfdir}/udev/rules.d/exorint.rules
    echo "#Custom Na16 rule to use ttyO2 as com2" >> ${D}${sysconfdir}/udev/rules.d/exorint.rules
    printf 'KERNEL=="ttyO2", SUBSYSTEM=="tty", SYMLINK="com2 ttyS1"\n' >> ${D}${sysconfdir}/udev/rules.d/exorint.rules
    printf 'KERNEL=="ttyS1", SUBSYSTEM=="tty", PROGRAM="/bin/ln -sf ${SERIAL_DEV}2 /dev/ttyS1"\n' >> ${D}${sysconfdir}/udev/rules.d/exorint.rules
}

do_install_append_us01-wu16 () {
   printf 'KERNEL=="spidev32766.0", SUBSYSTEM=="spidev", SYMLINK="spidev0.0"\n' >> ${D}${sysconfdir}/udev/rules.d/exorint.rules
}

do_install_append_hs07 () {
   printf 'KERNEL=="spidev32766.0", SUBSYSTEM=="spidev", SYMLINK="spidev0.0"\n' >> ${D}${sysconfdir}/udev/rules.d/exorint.rules
}

do_install_append_pa18 () {
    install -m 0644 ${WORKDIR}/exorint_pa18.rules ${D}${sysconfdir}/udev/rules.d/exorint_pa18.rules
}

RRECOMMENDS_${PN}_remove = "eudev-hwdb"

PACKAGE_ARCH= "${MACHINE_ARCH}"
