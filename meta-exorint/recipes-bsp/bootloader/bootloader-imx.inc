LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://README;beginline=1;endline=6;md5=157ab8408beab40cd8ce1dc69f702a6c"

require version.inc

COMPATIBLE_MACHINE = "usom03"

SRCNAME = "uboot"
SRCBRANCH = "uboot2014.04_uS01"
SRCREV = "8f9cb5886c3e250c4bae15056de7fccedd2f5be2"
SRC_URI = "git://github.com/ExorEmbedded/uboot-us01.git;branch=${SRCBRANCH}"

S = "${WORKDIR}/git"

inherit exorint-src
require ../u-boot.inc

SRC_URI += "file://fix-build-error-under-gcc6.patch \
            file://Add-linux-compiler-gcc7.h-to-fix-builds-with-gcc7.patch"

SRC_URI_append_usom03 = " file://fw_env_us03.config"

do_install_append_usom03 () {
    install -d ${D}${sysconfdir}
    install -m 644 ${WORKDIR}/fw_env_us03.config ${D}${sysconfdir}/fw_env.config
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

INSANE_SKIP_${PN}-env += "ldflags"

UBOOT_ONLY = "1"
UBOOT_SUFFIX = "imx"
