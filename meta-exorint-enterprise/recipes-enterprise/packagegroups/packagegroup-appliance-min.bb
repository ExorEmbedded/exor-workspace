SUMMARY = "Virtual package for Exor International minimal appliance"
LICENSE = "Proprietary"
PR = "r4"

inherit packagegroup

# core services
RDEPENDS_${PN} += "epad"
RDEPENDS_${PN} += "unstable-splash"

# cloud services
RDEPENDS_${PN} += "encloud"
RDEPENDS_${PN} += "router"

# no graphics - install pslash just because it's used for system health check
RDEPENDS_${PN} += "psplash"

# control, monitoring
RDEPENDS_${PN} += "jmuconfig"
