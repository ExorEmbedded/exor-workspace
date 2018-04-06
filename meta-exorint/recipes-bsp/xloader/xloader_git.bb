LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://README;beginline=1;endline=6;md5=157ab8408beab40cd8ce1dc69f702a6c"

require version.inc

SRCNAME = "uboot"
SRBCRANCH = "uboot2014.04_uS01"
SRCREV = "dce0a150313c0fe23156668a8d53a97c23747a70"

SRCBRANCH_ca16 = "uboot2014.04_uS01PGD_CA"
SRCREV_ca16 = "0ebbb748143281d4e11d92ee78815c27a0786f29"

SRCBRANCH_au16 = "uboot2014.04_us01au"
SRCREV_au16 = "f7566c8b30540bf02fdc84f6b04abeab4f46ed03"

inherit exorint-src
require ../u-boot.inc

COMPATIBLE_MACHINE = "usom01"

SPL_ONLY = "1"
SPL_BINARY = "MLO"
