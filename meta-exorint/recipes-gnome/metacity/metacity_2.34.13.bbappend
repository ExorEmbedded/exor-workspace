PR := "${PR}.x1"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://allow_offscreen.patch"
SRC_URI += "file://make-default-cursor-invisible.patch"
SRC_URI += "file://dont-steal-focus-at-startup.patch"

