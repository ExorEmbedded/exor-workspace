FILESEXTRAPATHS := "${THISDIR}/${PN}-${PV}"

PR := "${PR}.x1"

SRC_URI += "file://001-add-admin-group-to-sudoers.patch"
