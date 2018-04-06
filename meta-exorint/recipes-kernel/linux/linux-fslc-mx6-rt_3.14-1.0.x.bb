SUMMARY = "Realtime version of the FSL Community BSP i.MX6 Linux kernel with backported features and fixes"
DESCRIPTION = "Linux kernel based on Freescale 3.14.28 GA release, used by FSL Community BSP in order to \
provide support for i.MX6 based platforms and include official Linux kernel stable updates, backported \
features and fixes coming from the vendors, kernel community or FSL Community itself. \
In addition, this kernel has the realtime patch (PREEMPT_RT) applied."
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

#SRCNAME = "imx6linux"

SCRBRANCH = "master"
SRC_URI = "git://github.com/ExorEmbedded/linux-us03.git;branch=master"
SRCREV = "51b1b90da84146ac1712a20f670c58acd3f59c02"

KERNEL_RELEASE = "3.14"

COMPATIBLE_MACHINE = "(usom03)"

DEPENDS += "lzop-native bc-native"

require linux.inc
