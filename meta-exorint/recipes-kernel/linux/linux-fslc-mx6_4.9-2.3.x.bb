SUMMARY = "Realtime version of the FSL Community BSP i.MX6 Linux kernel with backported features and fixes"
DESCRIPTION = "Linux kernel based on Freescale 4.9.86 GA release, used by FSL Community BSP in order to \
provide support for i.MX6 based platforms and include official Linux kernel stable updates, backported \
features and fixes coming from the vendors, kernel community or FSL Community itself. \
In addition, this kernel has the realtime patch (PREEMPT_RT) applied."

SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

SRCNAME = "imx6linux"
SRCBRANCH = "4.9-2.3.x-imx"
SRCREV = "421158f9bf9ade2ee70fac0a2cb779a8b71510ae"

KERNEL_RELEASE = "4.9"
LINUX_VERSION = "4.9"

COMPATIBLE_MACHINE = "(x5)"

DEPENDS += "lzop-native bc-native"

require linux.inc
