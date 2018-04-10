DESCRIPTION = "JMCloud device configuration web application"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

PR = "x133"
SRCNAME = "jmuconfig"

SRCBRANCH = "rocko-1.x.x"
SRCREV = "6816f2953a2cd0c50fe341c1876fd3e0097c8a75"

SRCBRANCH_ca16 = "pgd_ca-1.x.x"
SRCREV_ca16 = "20ac95aab7d1e2a4a21d15de2b851eb6d6a27800"

inherit allarch
inherit exorint-src
inherit autotools
inherit update-rc.d

B = "${S}"
CLEANBROKEN = "1"

do_populate_sysroot[noexec] = "1"

# avoid parallelism which breaks target ordering assumptions
# not a big issue since jmuconfig only installs files without compilation
export PARALLEL_MAKE = ""

# customer-specific requirements
EXTRA_OEMAKE = ""
EXTRA_OEMAKE_bekaert = "JMUCONFIG_ENABLE_VNC=true"

DEPENDS += "nodejs-native rsync-native base-passwd"

RDEPENDS_${PN} += "nginx"
RDEPENDS_${PN} += "nodejs"
RDEPENDS_${PN} += "bash"

FILES_${PN} += "/usr/lib/jmuconfig/*"
FILES_${PN} += "/usr/share/jmuconfig/*"

INITSCRIPT_NAME = "jmuconfig"
INITSCRIPT_PARAMS = '${@bb.utils.contains("MACHINE_FEATURES", "fastboot", "defaults 80 70", "defaults 30 70",d)}'
INITSCRIPT_PARAMS_wu16 = "defaults 80 70"

PACKAGE_ARCH = "${MACHINE_ARCH}"
