DESCRIPTION = "Linux Kernel"
SECTION = "kernel"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=d7810fab7487fb0aad327b76f1be7cd7"

SRCNAME = "lke"

SCRBRANCH = "ti-linux-3.12.y"
SRCREV = "2829b79a24112cf94ed7846ee58d06f95434e3a8"

SCRBRANCH_ca16 = "ti-linux-3.12.y_pgd_ca"
SRCREV_ca16 = "8864dc0463b9d4dc697e24c1e2f910c9f445655f"

SCRBRANCH_wu16 = "ti-linux-3.12.y_wu16"
SRCREV_wu16 = "1593cf325cd0dd98b973277cf608857afce1c236"

SCRBRANCH_au16 = "ti-linux-3.12.y_au"
SRCREV_au16 = "2cbe4c5a86d7f6a1429d17d7cde498953a153a54"

SCRBRANCH_na16 = "ti-linux-3.12.y_na16"
SRCREV_na16 = "e8e42011c41662d0e6f592e63add45523999be4d"

KERNEL_RELEASE = "3.12.17"

COMPATIBLE_MACHINE = "(usom01|beaglebone)"

KERNEL_DEVICETREE = "\
        usom_eco.dtb \
        usom_etop5xx.dtb \
        usom_plcm07.dtb \
        usom_etop705.dtb \
"

KERNEL_DEVICETREE_ca16 = "usom_pgd_ca.dtb"

KERNEL_DEVICETREE_wu16 = "usom_wu16.dtb"

KERNEL_DEVICETREE_au16 = "usom_au.dtb"

KERNEL_DEVICETREE_na16 = "usom_na16.dtb"

KERNEL_DEVICETREE_beaglebone = "\
        am335x-bone.dtb \
        am335x-boneblack.dtb \
"

require linux.inc
