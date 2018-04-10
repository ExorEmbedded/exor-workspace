DESCRIPTION = "Exor International SDK"

require exorint.inc
require sdk-version.inc
require meta-toolchain-qt.inc

inherit core-image-mainos
inherit exorint-version
inherit populate_sdk

TOOLCHAIN_OUTPUTNAME = "${VERSION_HUMAN}"

IMAGE_FEATURES += "exorint-appliance"

do_image_tar[noexec] = "1"

SDKIMAGE_FEATURES += "dbg-pkgs"
