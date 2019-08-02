LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://README;beginline=1;endline=6;md5=157ab8408beab40cd8ce1dc69f702a6c"
LIC_FILES_CHKSUM_usom02 = "file://README;beginline=1;endline=6;md5=05908ffcfd3d7d846e5c7eafa9ab62de"

require version.inc

COMPATIBLE_MACHINE = "(usom01|usom02)"

SRCNAME = "uboot"
SRCBRANCH = "uboot2014.04_uS01"
SRCREV = "8f9cb5886c3e250c4bae15056de7fccedd2f5be2"

SRCBRANCH_ca16 = "uboot2014.04_uS01PGD_CA"
SRCREV_ca16 = "79b23fa8bc6a0f6d87b4f568106389fe0f1af04d"

SRCBRANCH_au16 = "uboot2014.04_us01au"
SRCREV_au16 = "f1004f5a7aa62738a8bce83d168978cacfdb0d2c"

SRCNAME_usom02 = "ubootus02"
SRCBRANCH_usom02 = "us02_etop"
SRCREV_usom02 = "3a89800eb99e70d2cdf0cd63f19f34fa59af7984"

inherit exorint-src
require ../u-boot.inc

SRC_URI += "file://fix-build-error-under-gcc6.patch \
	file://Add-linux-compiler-gcc7.h-to-fix-builds-with-gcc7.patch \
"
SRC_URI_append_usom01 = " file://fw_env_us01.config"

do_install_append_usom01 () {
    install -d ${D}${sysconfdir}
    install -m 644 ${WORKDIR}/fw_env_us01.config ${D}${sysconfdir}/fw_env.config
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

UBOOT_ONLY = "1"
UBOOT_SUFFIX = "img"

INSANE_SKIP_${PN}-env += "ldflags"
