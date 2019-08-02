DESCRIPTION = "Linux Kernel"
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

FILESEXTRAPATHS_prepend := "${THISDIR}/linux-${LINUX_VERSION}:"

SRCNAME = "lke"

SRCBRANCH = "ti-linux-3.12.y_RT"
SRCREV = "8d37c1ab38d3eec7328be3c72757388b42b7b177"

SRCBRANCH_ca16 = "ti-linux-3.12.y_pgd_ca"
SRCREV_ca16 = "24128234758bfb5c36551825659318c31e8e2f39"

SRCBRANCH_wu16 = "ti-linux-3.12.y_wu16"
SRCREV_wu16 = "073e26c2ab60fa38e0e7703eba1e56e848180365"

SRCBRANCH_au16 = "ti-linux-3.12.y_au"
SRCREV_au16 = "2f6eaebf073328a26a25df8d4f900def0b796734"

LINUX_VERSION = "3.12"

COMPATIBLE_MACHINE = "(usom01|beaglebone)"

KERNEL_DEVICETREE = "\
        usom_eco.dtb \
        usom_etop5xx.dtb \
        usom_plcm07.dtb \
        usom_etop705.dtb \
"

KERNEL_DEVICETREE_ca16 = "\
		usom_pgd_ca.dtb \
		usom_pgdx7_ca.dtb \
"

KERNEL_DEVICETREE_wu16 = "usom_wu16.dtb"

KERNEL_DEVICETREE_au16 = "usom_au.dtb"

KERNEL_DEVICETREE_na16 = "usom_na16.dtb"

#KERNEL_DEVICETREE_beaglebone = "\
#        am335x-bone.dtb \
#        am335x-boneblack.dtb \
#"

require linux.inc

SRC_URI += "file://0001-change-extern-inline-to-static-inline-in-glue-cache.patch \
	file://0002-Add-compiler-gcc6.h.patch \
	file://0003-Add-compiler-gcc7.h.patch \
"
