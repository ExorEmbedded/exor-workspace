# Patch resolution exit upon missing interfaces

PR = "r10"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

SRC_URI += "file://avoid-exit-on-missing-interfaces.patch"
