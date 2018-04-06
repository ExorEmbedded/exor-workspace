# Freescale gstplaybin2 rawvideo support

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_mx6 = " file://gstplaybin2-rawvideo-support.patch"

PACKAGE_ARCH = "${MACHINE_ARCH}"
