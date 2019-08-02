LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://README;beginline=1;endline=6;md5=157ab8408beab40cd8ce1dc69f702a6c"

require version.inc

COMPATIBLE_MACHINE = "nsom01"

SRCNAME = "uboot"
SRCBRANCH = "uboot2017.07_nS01"
SRCREV = "6c7dd54b2c569db7850ac82479c2e0d3af1728af"

inherit exorint-src
require ../u-boot.inc

PACKAGE_ARCH = "${MACHINE_ARCH}"

UBOOT_ONLY = "1"
UBOOT_SUFFIX = "imx"
UBOOT_MACHINE ?= "ns01-imx6ul_config"
PROVIDES += "bootloader"
