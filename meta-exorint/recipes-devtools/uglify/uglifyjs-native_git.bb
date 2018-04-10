DESCRIPTION = "JavaScript parser / mangler / compressor / beautifier library for NodeJS"
SECTION = "devel"

DEPENDS = "nodejs-native"

LICENSE = "BSD-2-Clause"
LIC_FILES_CHKSUM = "file://README.org;beginline=568;endline=595;md5=fc1b8a56c0d33548ca26ad25d1c70ba4"

PR = "r0"

SRCNAME = "UglifyJS"
SRC_URI = "git://github.com/mishoo/${SRCNAME}.git;protocol=http"
SRCREV = "2bc1d02363db3798d5df41fb5059a19edca9b7eb"
S = "${WORKDIR}/git"

inherit native

do_install() {
    install -m 0755 bin/uglifyjs ${bindir}
    install -m 0644 uglify-js.js ${bindir}/..
    install -m 0644 lib/*.js ${libdir}
}
