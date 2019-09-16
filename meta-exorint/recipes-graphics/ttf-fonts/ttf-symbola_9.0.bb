DESCRIPTION = "Symbol blocks of The Unicode Standard"
HOMEPAGE = "http://users.teilar.gr/~g1951d/"
LICENSE = "Free"
LIC_FILES_CHKSUM = "file://Symbola.pdf;md5=bec06f43ce3d650d512aa33b853ec111"
SRC_DISTRIBUTE_LICENSES += "${PN}"
PR = "r5"

SRC_URI = "git://github.com/ExorEmbedded/ttf-symbola.git"
SRCREV = "d4ae752ec1fc9116d449cd277993129c10d45db2"

SRC_URI[md5sum] = "be7b84a1e5ba3fce6bf73338aa7013cc"
SRC_URI[sha256sum] = "8101ae2282e0ee788dceabed7d9a49be189ad0196028b2c29d06b45821611f05"

S = "${WORKDIR}/git"

# Local mirror
#SRCREV = "25544be2f23f0f5c30431a28e65b358e2603da8b"
#inherit exorint-src

PACKAGES += "${PN}-hint"
FONT_PACKAGES = "${PN} ${PN}-hint"

require ttf.inc

FILES_${PN} += "${datadir} ${datadir}/fonts ${datadir}/fonts/truetype/Symbola.ttf"
FILES_${PN}-hint = "${datadir}/fonts/truetype/Symbola_hint.ttf"
