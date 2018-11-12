DESCRIPTION = "Provides a unified links for use GPIO in JMobile"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://LICENSE file://gpio.sh"
SRC_URI_append_us01-wu16 += "file://gpio_ti"
SRC_URI_append_us03-wu16 += "file://gpio_imx"

S = "${WORKDIR}"

PR = "r2"

inherit update-rc.d

INITSCRIPT_NAME = "gpio.sh"
INITSCRIPT_PARAMS = "start 51 S ."

RDEPENDS_${PN} += "bash"

do_install_append_us01-wu16() {
	install -d ${D}${sysconfdir}/default/
	install -m 644 gpio_ti ${D}/${sysconfdir}/default/gpio
}

do_install_append_us03-wu16() {
	install -d ${D}${sysconfdir}/default/
	install -m 644 gpio_imx ${D}/${sysconfdir}/default/gpio
}

do_install() {
	install -d ${D}${sysconfdir}/init.d
	install -m 0755 gpio.sh ${D}/${sysconfdir}/init.d/gpio.sh
}

FILES_${PN} += "${sysconfdir}/init.d/"
