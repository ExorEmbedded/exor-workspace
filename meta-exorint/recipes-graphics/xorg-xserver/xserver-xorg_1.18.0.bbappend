FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PACKAGECONFIG_remove = "glamor"

SRC_URI_append_us03-wu16 = " file://removed_first_flush.patch"
