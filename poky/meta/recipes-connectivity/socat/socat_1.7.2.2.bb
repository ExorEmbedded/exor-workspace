DESCRIPTION = "Socat is a relay for bidirectional data \
transfer between two independent data channels."
HOMEPAGE = "http://www.dest-unreach.org/socat/"

SECTION = "console/network"

DEPENDS = "openssl readline"

LICENSE = "GPL-2.0+-with-OpenSSL-exception"
LIC_FILES_CHKSUM = "file://COPYING;md5=18810669f13b87348459e611d31ab760 \
                    file://README;beginline=252;endline=282;md5=79246f11a1db0b6ccec54d1fb711c01e"


SRC_URI = "http://www.dest-unreach.org/socat/download/socat-${PV}.tar.bz2 \
           file://compile.patch \
           file://fix-xxx_SHIFT-autoheader.patch"

SRC_URI[md5sum] = "39231e512d8052f328552865df15d42f"
SRC_URI[sha256sum] = "9a167af11a4d3809cbc66f5e2dcb39b6e371251282ef5de6ea6ff0c4be8a953c"

PACKAGECONFIG ??= "tcp-wrappers"
PACKAGECONFIG[tcp-wrappers] = "--enable-libwrap,--disable-libwrap,tcp-wrappers"

EXTRA_OECONF += "ac_cv_have_z_modifier=yes sc_cv_sys_crdly_shift=9 \
        sc_cv_sys_tabdly_shift=11 sc_cv_sys_csize_shift=4 \
        ac_cv_ispeed_offset=13 \
"

inherit autotools

do_configure_prepend() {
    sed '/AC_DEFINE_UNQUOTED(ISPEED_OFFSET/a\AC_DEFINE(OSPEED_OFFSET,\
(ISPEED_OFFSET+1)\ ,\ [have\ ospeed\ offset])' -i ${S}/configure.in
}

do_install_prepend () {
    mkdir -p ${D}${bindir}
    install -d ${D}${bindir} ${D}${mandir}/man1
}
