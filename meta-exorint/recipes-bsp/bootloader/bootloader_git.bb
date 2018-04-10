LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://README;beginline=1;endline=6;md5=157ab8408beab40cd8ce1dc69f702a6c"
LIC_FILES_CHKSUM_usom02 = "file://README;beginline=1;endline=6;md5=05908ffcfd3d7d846e5c7eafa9ab62de"

require version.inc

COMPATIBLE_MACHINE = "(usom01|usom02)"

SRCNAME = "uboot"
SRCBRANCH = "uboot2014.04_uS01"
SRCREV = "9bb7cbd5fecacfd8794ee47c7cd700de00ac5e3a"

SRCBRANCH_ca16 = "uboot2014.04_uS01PGD_CA"
SRCREV_ca16 = "1d5794ab082f18b587fb3091c968ede509a50e94"

SRCBRANCH_au16 = "uboot2014.04_us01au"
SRCREV_au16 = "57081a7176a5c773a95469df517de96e297deb4f"

SRCNAME_usom02 = "ubootus02"
SRCBRANCH_usom02 = "us02_etop"
SRCREV_usom02 = "057343b8493f7997e09a8e52c71e78502c963800"

inherit exorint-src
require ../u-boot.inc

SRC_URI += "file://fix-build-error-under-gcc6.patch"
SRC_URI_append_usom01 = " file://fw_env_us01.config"

do_install_append_usom01 () {
    install -d ${D}${sysconfdir}
    install -m 644 ${WORKDIR}/fw_env_us01.config ${D}${sysconfdir}/fw_env.config
}

PACKAGE_ARCH = "${MACHINE_ARCH}"

UBOOT_ONLY = "1"
UBOOT_SUFFIX = "img"
