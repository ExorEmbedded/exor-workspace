DESCRIPTION = "Symbol blocks of The Unicode Standard"
HOMEPAGE = "http://users.teilar.gr/~g1951d/"
LICENSE = "Free"
LIC_FILES_CHKSUM = "file://Symbola.pdf;md5=bec06f43ce3d650d512aa33b853ec111"
SRC_DISTRIBUTE_LICENSES += "${PN}"
PR = "r4"

# Original source (unreliable)
#SRC_URI = "http://users.teilar.gr/~g1951d/Symbola.zip"

# Local mirror
SRCREV = "d4ae752ec1fc9116d449cd277993129c10d45db2"
SRC_URI = "git://github.com/ExorEmbedded/ttf-symbola.git;branch=master"

inherit exorint-src

PACKAGES += "${PN}-hint"
FONT_PACKAGES = "${PN} ${PN}-hint"

require ttf.inc

FILES_${PN} += "${datadir}/fonts/truetype/Symbola.ttf"
FILES_${PN}-hint = "${datadir}/fonts/truetype/Symbola_hint.ttf"
