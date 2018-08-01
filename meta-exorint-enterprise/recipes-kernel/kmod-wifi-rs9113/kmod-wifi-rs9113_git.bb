DESCRIPTION = "Kernel driver for Redpine's RS9113 n-Link WiFi Module"
DESCRIPTION_${PN}-reset  = "Wifi reset"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

inherit module
inherit exorint-src

PACKAGE_ARCH = "${MACHINE_ARCH}"
RDEPENDS_${PN}-reset = "${PN}"

SRCBRANCH = "redpine_1.6"
PR = "x16.1"
SRCREV = "28f848c4e6704fe7e350ab74a26cfc47284041c6"
SRC_URI += "file://init.sh \
            file://reset_wifi.sh \
            file://wifi_gpio_us03_wu16 \
            file://wifi_gpio_us01_wu16 \
            file://wifi_gpio_us03_jsxx \
            "

DEPENDS += "libnl openssl"

export KERNELDIR = "${STAGING_KERNEL_DIR}"
export OECORE_TARGET_SYSROOT = "${STAGING_DIR_TARGET}"

# Note: builds both kernel module and Redpine utils
do_compile() {
    ${MAKE}
}

do_install() {
    # install kernel modules
    INSTALLDIR="${D}${base_libdir}/modules/${KERNEL_VERSION}/kernel/drivers/EXTERNAL/${PN}"
    install -d ${INSTALLDIR}
    install -m 0644 release/*${KERNEL_OBJECT_SUFFIX} ${INSTALLDIR}

    # install firmware
    install -d ${D}${base_libdir}/firmware/${PN}
    install -m 0644 release/firmware/* ${D}${base_libdir}/firmware/${PN}

    # install utilities
    install -d ${D}${sbindir}
    install -m 0755 release/onebox_util ${D}${sbindir}

    # install init script
    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/init.sh ${D}${sysconfdir}/init.d/networking_${PN}.sh
    install -m 0755 ${WORKDIR}/reset_wifi.sh ${D}${sysconfdir}/init.d/networking_reset_${PN}.sh

}

do_install_append_us03-jsxx() {
    install -d ${D}${sysconfdir}/default/
    install -m 0644 ${WORKDIR}/wifi_gpio_us03_jsxx ${D}${sysconfdir}/default/wifi_gpio
}

do_install_append_us03-wu16() {
    install -d ${D}${sysconfdir}/default/
    install -m 0644 ${WORKDIR}/wifi_gpio_us03_wu16 ${D}${sysconfdir}/default/wifi_gpio
}

do_install_append_us01-wu16() {
    install -d ${D}${sysconfdir}/default/
    install -m 0644 ${WORKDIR}/wifi_gpio_us01_wu16 ${D}${sysconfdir}/default/wifi_gpio
}

inherit update-rc.d

# /etc/init.d/networking must depend on this script (S=39, K=40)
PACKAGES =+ "${PN}-reset"
FILES_${PN}-reset     = "${sysconfdir}/init.d/networking_reset_${PN}.sh"


INITSCRIPT_PACKAGES += "${PN} ${PN}-reset"
INITSCRIPT_NAME_${PN} = "networking_${PN}.sh"
INITSCRIPT_NAME_${PN}-reset = "networking_reset_${PN}.sh"
INITSCRIPT_PARAMS_${PN} = "start 02 5 . stop 41 0 6 1 ."
INITSCRIPT_PARAMS_${PN}_wu16 = "start 28 5 . stop 41 0 6 1 ."
INITSCRIPT_PARAMS_${PN}-reset = "start 02 S ."


FILES_${PN} += "${sbindir}/*"
FILES_${PN} += "${base_libdir}/firmware/${PN}/*"
FILES_${PN} += "${sysconfdir}/init.d/*"
FILES_${PN} += "${sysconfdir}/rcS.d/*"
FILES_${PN} += "${sysconfdir}/default/*"

INSANE_SKIP_${PN} = "ldflags"
