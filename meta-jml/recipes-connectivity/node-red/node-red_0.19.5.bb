SECTION = "network"
SUMMARY = "Flow-based programming for the Internet of Things"
DESCRIPTION = "Node-RED is a programming tool for wiring together hardware devices, APIs and online services in new and interesting ways."
HOMEPAGE = "https://nodered.org/"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d6f37569f5013072e9490d2194d10ae6"

FILESEXTRAPATHS_prepend := "${THISDIR}/jmlauncher:"

inherit npm-install jml-package
#inherit exorint-src

PR = "0.1"
PKG_VERSION = "${PV}-${PR}"

SRCBRANCH = "master"
SRCREV = "c6fccb2fb9b684d809342cb509f58fa8fb53bfa6"
SRC_URI = "git://github.com/ExorEmbedded/jmnodered.git;branch=${SRCBRANCH}"

SRC_URI += "https://github.com/node-red/node-red/archive/${PV}.zip"
SRC_URI[md5sum] = "af0988126e77d7b76075fdc4d1177cd9"
SRC_URI[sha256sum] = "719eb94821cfdf0c0bfeba449efb3ea88bc26613d5938f4034762bff9d20ed02"

SRC_URI += "file://license.html"

S = "${WORKDIR}/${PN}-${PV}"

JMNODES_DEPS = "azure-iot-common \
	eventsource \
	aws-iot-device-sdk \
	randomstring \
	amqp10 \
	protobufjs "

do_npm_install_append() {

	oe_runnpm run build

        # Uninstall dev dependencies
	oe_runnpm prune --production

        # Install jmobile nodes dependencies
        oe_runnpm install ${JMNODES_DEPS}

}

do_install_append() {

        cp -r ${S}/* ${D}/deploy

	# Copy jmobile nodes
        mkdir -p ${D}/deploy/nodes/core/jmobile
	cp -r ${WORKDIR}/git/* ${D}/deploy/nodes/core/jmobile
}

do_npm_shrinkwrap[noexec] = "1"

FILES_${PN} += "deploy/* \
	deploy/*/* "
