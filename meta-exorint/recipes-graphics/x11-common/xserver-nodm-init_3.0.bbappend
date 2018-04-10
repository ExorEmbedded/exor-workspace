R := "${PR}.x1"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# redefine boot order
INITSCRIPT_PARAMS = "start 80 5 2 . stop 99 0 1 6 ."

do_install_append () {

    # Remove config files which have migrated to base
    rm ${D}${sysconfdir}/X11/Xsession
    rm ${D}${sysconfdir}/X11/Xsession.d/90XWindowManager.sh
}

do_install_append_usom03 () {

    # Disable cursor causing graphical glitches with vivante gpu
    sed -i'' 's:ARGS="\(.*\)":ARGS="-nocursor \1":' ${D}${sysconfdir}/default/xserver-nodm

}

python () {
    if bb.utils.contains ('MACHINE_FEATURES', 'fastboot', True, False, d):
        d.setVar('INITSCRIPT_PARAMS', "start 10 5 2 . stop 99 0 1 6 .")
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
