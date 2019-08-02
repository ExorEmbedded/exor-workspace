INITSCRIPT_PARAMS = "start 03 5 3 2 . stop 97 0 1 6 ."

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:${THISDIR}/files:"

#SRC_URI += "file://remove-exor-refs.patch"

#Hard fastboot
INITSCRIPT_PARAMS_wu16 = "start 27 . stop 97 ."

EXTRA_OECONF += "--enable-abstract-sockets=no"

PR := "${PR}.x4"
