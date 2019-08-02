DESCRIPTION = "X application"
DESCRIPTION = "Xsplash is a small X11 application."
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

PR = "r17"
SRCNAME = "ltools-${BPN}"
SRCREV = "a880e7694ed92de15c74c1bb29a19318094d7582"
inherit exorint-src
inherit autotools
inherit pkgconfig

SRC_URI_append_us01-wu16 += "file://0001-add-backlight-support.patch \
                             file://0002-remove-window-manager-decorations.patch \
                             file://0003-launch-configos-with-long-press-of-F8key.patch \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"

# avoid Makefile failure when build dir is not source dir
export B = "${S}"

do_configure_usom01() {
    CONFIGURE_AC=configure.ac oe_runconf TARGET=USOM01
}

do_configure_usom02() {
    CONFIGURE_AC=configure.ac oe_runconf TARGET=USOM02
}

do_configure_usom03() {
    CONFIGURE_AC=configure.ac oe_runconf TARGET=USOM03
}

do_configure_nsom01() {
    CONFIGURE_AC=configure.ac oe_runconf TARGET=NSOM01
}

do_install() {
	mkdir -p ${D}/${bindir}/
	install -m 0755 xsplash  ${D}/${bindir}/
}

do_install_append_usom03() {
	install -m 0755 setoverlay  ${D}/${bindir}/
}

DEPENDS += " virtual/libx11"
