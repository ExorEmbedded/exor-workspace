DESCRIPTION = "ConfigOS Main Image"

require exorint.inc
require configos-version.inc
inherit exorint-version
inherit core-image-configos

IMAGE_NAME = "${VERSION_HUMAN}"
IMAGE_LINK_NAME = "${VERSION_HUMAN_NOVER}"
IMAGE_FEATURES += "exorint-appliance"

