DESCRIPTION = "Port of YUI CSS Compressor from Java to NodeJS"
SECTION = "devel"

DEPENDS = "nodejs-native"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=39ae27640f4e720c7c7897695071ca4e"

PR = "r0"

FILESEXTRAPATHS_prepend := "${THISDIR}/uglifycss:"

SRCNAME = "UglifyCSS"
SRC_URI = "git://github.com/fmarcia/${SRCNAME}.git;protocol=http"
SRC_URI += "file://010-fix-bad-require.patch"
SRCREV = "11d7aeaf4603df5b2cc2b23a7c5a4a106662dae9"
S = "${WORKDIR}/git"

inherit native

do_install() {
    install -m 0755 uglifycss ${bindir}
    install -m 0644 uglifycss-lib.js ${bindir}/..
}
