SUMMARY = "Realtime version of the FSL Community BSP i.MX6 Linux kernel with backported features and fixes"
DESCRIPTION = "Linux kernel based on Freescale 3.14.28 GA release, used by FSL Community BSP in order to \
provide support for i.MX6 based platforms and include official Linux kernel stable updates, backported \
features and fixes coming from the vendors, kernel community or FSL Community itself. \
In addition, this kernel has the realtime patch (PREEMPT_RT) applied."
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

SRCNAME = "imx6linux"
SRCBRANCH = "4.1-2.0.x-imx-RT"
SRCREV = "11f1c688731ecdba107ef459ad97d8387665b59d"

KERNEL_RELEASE = "4.1"

COMPATIBLE_MACHINE = "(nsom01)"

DEPENDS += "lzop-native bc-native"

require linux.inc
