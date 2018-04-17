UBOOT_MACHINE ?= "mx6q_usom_config"
TAGNAME = "B03Q"

require bootloader-imx.inc

# Avoid conflicting with bootloader-imx6d
PROVIDES = ""
