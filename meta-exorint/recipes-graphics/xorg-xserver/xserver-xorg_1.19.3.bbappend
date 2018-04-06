FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

OPENGL_PKGCONFIGS = ""

SRC_URI_append_us03-hsxx = " file://us03-use-vsync-on-rotation.patch"
SRC_URI_append_us03-jsxx = " file://us03-use-vsync-on-rotation.patch"

SRC_URI_append_us03-wu16 = " file://removed_first_flush.patch"

PACKAGE_ARCH= "${MACHINE_ARCH}"
