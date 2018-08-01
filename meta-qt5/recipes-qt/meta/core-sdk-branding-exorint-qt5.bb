DESCRIPTION = "Exor International SDK"

require recipes-image/images/exorint.inc
require recipes-image/images/sdk-version.inc

inherit core-image-mainos
inherit exorint-version
inherit populate_sdk populate_sdk_qt5

TOOLCHAIN_OUTPUTNAME = "${VERSION_HUMAN}-qt5"

IMAGE_FEATURES += "exorint-appliance"
SDKIMAGE_FEATURES += "dbg-pkgs"

IMAGE_INSTALL_remove = "jmuconfig epad kmod-wifi-rs9113"

TOOLCHAIN_HOST_TASK_append = " nativesdk-python-threading nativesdk-python-json "

do_image_tar[noexec] = "1"
