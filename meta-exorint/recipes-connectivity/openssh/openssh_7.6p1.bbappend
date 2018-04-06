FILESEXTRAPATHS := "${THISDIR}/${PN}-${PV}"

PR := "${PR}.x0"

# Disabled by default
INITSCRIPT_PARAMS_${PN}-sshd = "start 10 . stop 10 ."

# Enabled only upon specific customer request
INITSCRIPT_PARAMS_${PN}-sshd_bekaert = "defaults 85 5"
