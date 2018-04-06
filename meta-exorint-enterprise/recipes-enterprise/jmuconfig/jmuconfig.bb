DESCRIPTION = "JMCloud device configuration web application"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

PR = "x132"
SRCNAME = "jmuconfig"

SRCBRANCH = "exorint-1.x.x"
SRCREV = "d080db5a47c7ab3118bf8dc7b4dcf738330c9708"

SRCBRANCH_ca16 = "pgd_ca-1.x.x"
SRCREV_ca16 = "20ac95aab7d1e2a4a21d15de2b851eb6d6a27800"

inherit allarch
inherit exorint-src
inherit autotools
inherit update-rc.d

# avoid parallelism which breaks target ordering assumptions
# not a big issue since jmuconfig only installs files without compilation
export PARALLEL_MAKE = ""

# customer-specific requirements
EXTRA_OEMAKE = ""
EXTRA_OEMAKE_bekaert = "JMUCONFIG_ENABLE_VNC=true"

RDEPENDS_${PN} += "nginx"
RDEPENDS_${PN} += "nodejs"

FILES_${PN} += "/usr/lib/jmuconfig/*"
FILES_${PN} += "/usr/share/jmuconfig/*"

INITSCRIPT_NAME = "jmuconfig"
INITSCRIPT_PARAMS = '${@base_contains("MACHINE_FEATURES", "fastboot", "defaults 80 70", "defaults 30 70",d)}'
INITSCRIPT_PARAMS_wu16 = "defaults 80 70"

PACKAGE_ARCH = "${MACHINE_ARCH}"
