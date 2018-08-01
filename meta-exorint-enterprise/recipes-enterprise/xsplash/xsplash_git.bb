DESCRIPTION = "X application"
DESCRIPTION = "Xsplash is a small X11 application."
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

PR = "r13"
SRCNAME = "ltools-${BPN}"

SRCBRANCH = "exorint-1.x.x"
SRCREV = "18fcd263254acb3cc5e0af7dad85ccb59e9e7bb8"

inherit exorint-src

inherit autotools
inherit pkgconfig

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

do_install() {
	mkdir -p ${D}/${bindir}/
	install -m 0755 xsplash  ${D}/${bindir}/
}

do_install_append_usom03() {
	install -m 0755 setoverlay  ${D}/${bindir}/
}

DEPENDS += " virtual/libx11"
