FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://0001-enable-webkit-gcc7-build.patch \
	file://0010-Fix-leak-in-QSslCertificate-subjectAlternativeNames.patch \
	file://0002-webkit-use-monotonic-timer.patch \
"

SRC_URI_append_usom03 = " file://qt4-egl-config-test-defines.patch"

DEPENDS += "libxi"

CXXFLAGS_append = " -fpermissive -std=gnu++98"

INSANE_SKIP_${PN} = "pkgconfig"
