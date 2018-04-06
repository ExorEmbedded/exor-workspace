LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://README;beginline=1;endline=6;md5=157ab8408beab40cd8ce1dc69f702a6c"

require version.inc

COMPATIBLE_MACHINE = "usom03"

SRCNAME = "uboot"
SRCBRANCH = "uboot2014.04_uS01"
SRCREV = "9bb7cbd5fecacfd8794ee47c7cd700de00ac5e3a"
SRC_URI = "git://github.com/ExorEmbedded/uboot-us01.git"

S = "${WORKDIR}/git"

#inherit exorint-src
require ../u-boot.inc

SRC_URI_append_usom03 = " file://fw_env_us03.config"

do_install_append_usom03 () {
    install -d ${D}${sysconfdir}
    install -m 644 ${WORKDIR}/fw_env_us03.config ${D}${sysconfdir}/fw_env.config
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

UBOOT_ONLY = "1"
UBOOT_SUFFIX = "imx"
