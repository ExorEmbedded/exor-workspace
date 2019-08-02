SUMMARY = "Realtime version of the FSL Community BSP i.MX6 Linux kernel with backported features and fixes"
DESCRIPTION = "Linux kernel based on Freescale 3.14.28 GA release, used by FSL Community BSP in order to \
provide support for i.MX6 based platforms and include official Linux kernel stable updates, backported \
features and fixes coming from the vendors, kernel community or FSL Community itself. \
In addition, this kernel has the realtime patch (PREEMPT_RT) applied."
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

FILESEXTRAPATHS_prepend := "${THISDIR}/linux-${LINUX_VERSION}:"

SRCNAME = "imx6linux"
SRCBRANCH = "master"
SRCREV = "c58d537f01ccbcbb8f3a6dbf9b339aee5b693d8f"
SRC_URI = "git://github.com/ExorEmbedded/linux-us03.git;branch=${SRCBRANCH}"

LINUX_VERSION = "3.14"

COMPATIBLE_MACHINE = "(usom03)"

DEPENDS += "lzop-native bc-native"

require linux.inc

SRC_URI += " \
    file://0001-use-static-inline-in-ARM-ftrace.patch \
    file://0002-change-extern-inline-to-static-inline-in-glue-cache.patch \
    file://0003-genksyms-fix-typeof-handling.patch \
    file://0004-Add-compiler-gcc6.h.patch \
    file://0005-Add-compiler-gcc7.h.patch \
    file://fix-video-playback-blackscreen-issues.patch \ 
"

SRC_URI_append_jsxx-1ghz = " file://us03dl-enable-1ghz-mode.patch"
