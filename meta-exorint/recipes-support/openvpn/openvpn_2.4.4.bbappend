FILESEXTRAPATHS := "${THISDIR}/${PN}-${PV}"

PR := "${PR}.x0"

SRC_URI += "file://custom_control_message.patch"
