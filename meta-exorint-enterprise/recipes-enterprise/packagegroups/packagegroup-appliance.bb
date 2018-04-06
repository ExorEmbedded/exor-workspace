SUMMARY = "Virtual package for Exor International appliance"
LICENSE = "Proprietary"
PR = "r1"

inherit packagegroup

# everything contained in minimal appliance (no X11)
RDEPENDS_${PN} += "packagegroup-appliance-min"

# graphical applications
#RDEPENDS_${PN} += "jmuconfig-app"
#RDEPENDS_${PN} += "jmlauncher"
