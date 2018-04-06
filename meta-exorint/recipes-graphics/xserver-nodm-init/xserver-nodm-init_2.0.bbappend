# redefine boot order

FILESEXTRAPATHS := "${THISDIR}/files"

INITSCRIPT_PARAMS = '${@base_contains("MACHINE_FEATURES", "fastboot", "start 8 5 2 . stop 99 0 1 6 .", "start 80 5 2 . stop 99 0 1 6 .",d)}'
