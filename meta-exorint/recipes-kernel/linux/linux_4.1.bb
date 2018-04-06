DESCRIPTION = "Linux Kernel"
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

SRCNAME = "alteralinux"
SRCBRANCH = "4.1-LTS_us02_etop"
SRCREV = "22a9b237842221a5f6ac0e507f7cacdbf1eebd18"

KERNEL_RELEASE = "4.1"

COMPATIBLE_MACHINE = "(usom02)"

KERNEL_DEVICETREE = "usom_etop6xx.dtb"

require linux.inc
