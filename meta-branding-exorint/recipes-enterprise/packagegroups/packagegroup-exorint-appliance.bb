SUMMARY = "Virtual package for Exor International appliance"
LICENSE = "Proprietary"
PR = "r0"

inherit packagegroup

RDEPENDS_${PN} += "packagegroup-appliance"
