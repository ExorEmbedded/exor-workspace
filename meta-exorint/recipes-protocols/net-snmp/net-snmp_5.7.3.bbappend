FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PR := "${PR}.x0"

# Disabled by default
INITSCRIPT_PARAMS_${PN}-server-snmpd = "start 20 . stop 20 ."
