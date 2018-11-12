FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append_class-native = " file://fix-npm-bin-remove-error.patch"
