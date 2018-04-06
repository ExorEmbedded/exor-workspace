FILESEXTRAPATHS := "${THISDIR}/files"

PR := "${PR}.x0"

# Disabled by default
INITSCRIPT_PARAMS_${PN}-server = "start 20 . stop 20 ."
