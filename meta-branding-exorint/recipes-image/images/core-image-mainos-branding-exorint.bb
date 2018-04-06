DESCRIPTION = "MainOS Main Image"

require exorint.inc
require mainos.inc
require mainos-version.inc
inherit exorint-version
inherit core-image-mainos

IMAGE_NAME = "${VERSION_HUMAN}"
IMAGE_LINK_NAME = "${VERSION_HUMAN_NOVER}"
IMAGE_FEATURES += "exorint-appliance"

ROOTFS_POSTPROCESS_COMMAND += "\
    echo ${VERSION} > ${IMAGE_ROOTFS}/etc/migrations/version; \
"
