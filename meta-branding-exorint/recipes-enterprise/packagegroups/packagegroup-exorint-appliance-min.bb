SUMMARY = "Virtual package for Exor International minimal appliance"
LICENSE = "Proprietary"
PR = "r0"

inherit packagegroup

RDEPENDS_${PN} += "packagegroup-appliance-min"
