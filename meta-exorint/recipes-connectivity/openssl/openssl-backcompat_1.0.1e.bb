SUMMARY = "OpenSSL 1.0.1e binary libraries"
DESCRIPTION = "OpenSSL 1.0.1e binary libraries for compatibility with old versions of JMobile"
HOMEPAGE = "http://www.openssl.org/"
BUGTRACKER = "http://www.openssl.org/news/vulnerabilities.html"
SECTION = "libs/network"
LICENSE = "openssl"
LIC_FILES_CHKSUM = "file://LICENSE;md5=057d9218c6180e1d9ee407572b2dd225"

PR := "x0"
S = "${WORKDIR}"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRC_URI += "file://LICENSE"
SRC_URI += "file://libssl.so.1.0.0"
SRC_URI += "file://libcrypto.so.1.0.0"

INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
INHIBIT_PACKAGE_STRIP = "1"

FILES_${PN} += "${libdir}/*.so"

do_install () {
    install -d ${D}${libdir}
    install *.so* ${D}${libdir}
}
