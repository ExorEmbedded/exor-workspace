INITSCRIPT_PARAMS = "start 03 5 3 2 . stop 97 0 1 6 ."

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
#Hard fastboot
INITSCRIPT_PARAMS_wu16 = "start 27 5 3 2 . stop 97 0 1 6 ."

EXTRA_OECONF += "--enable-abstract-sockets=no"

PR := "${PR}.x2"
