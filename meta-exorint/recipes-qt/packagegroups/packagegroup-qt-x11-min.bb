SUMMARY = "Group of minimal Qt packages for X11"

LICENSE = "MIT"

PR = "r1"

inherit packagegroup

RDEPENDS_${PN} += "libqtcore4"
RDEPENDS_${PN} += "libqtnetwork4"
RDEPENDS_${PN} += "libqtgui4"
RDEPENDS_${PN} += "libqtwebkit4"
RDEPENDS_${PN} += "libqtopengl4"
