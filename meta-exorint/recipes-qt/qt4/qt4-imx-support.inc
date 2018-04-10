FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PR = "x2"

SRC_URI_append_mx6 += "file://0001-Add-support-for-i.MX-codecs-to-phonon.patch"

QT_CONFIG_FLAGS_append_mx6 = " -I${STAGING_KERNEL_DIR}/include/uapi \
                               -I${STAGING_KERNEL_DIR}/include/ "
