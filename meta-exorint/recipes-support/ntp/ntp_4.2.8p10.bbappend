FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
FILESEXTRAPATHS_prepend_carel := "${THISDIR}/files/carel:${THISDIR}/files:"

PR := "${PR}.x2"
SRC_URI_append = "file://0001-Start-ntpd-daemon-with-unsync-status.patch "

FILES_${PN} += "${sbindir}/ntpdate"

PACKAGE_ARCH = "${MACHINE_ARCH}"

# Disabled by default
INITSCRIPT_PARAMS = "start 10 . stop 10 ."
