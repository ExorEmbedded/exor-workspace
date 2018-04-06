SUMMARY = "PCI Utilities"
DESCRIPTION = 'The PCI Utilities package contains a library for portable access \
to PCI bus configuration space and several utilities based on this library.'
DESCRIPTION_pciutils-ids = 'The list of PCI IDs for pciutils'
HOMEPAGE = "http://atrey.karlin.mff.cuni.cz/~mj/pciutils.shtml"
SECTION = "console/utils"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=751419260aa954499f7abaabaa882bbe"
DEPENDS = "zlib kmod"
RDEPENDS_${PN} = "${PN}-ids"
PR = "r0"

SRC_URI = "${KERNELORG_MIRROR}/software/utils/pciutils/pciutils-${PV}.tar.bz2 \
           file://configure.patch \
           file://lib-build-fix.patch \
           file://guess-fix.patch \
           file://makefile.patch"

SRC_URI[md5sum] = "d73a1b35e5d5efa70e8476d5917de11f"
SRC_URI[sha256sum] = "b816943bb06c3338d98e2c705e3b76c9e513830f1f15c76d60e549f965d22a35"

PARALLEL_MAKE = ""

PCI_CONF_FLAG = "ZLIB=yes DNS=yes SHARED=yes"

# see configure.patch
do_configure () {
	(
	  cd lib && \
	  ${PCI_CONF_FLAG} ./configure ${PV} ${datadir} ${TARGET_OS} ${TARGET_ARCH}
	)
}

do_compile_prepend () {
	# Avoid this error:  ln: failed to create symbolic link `libpci.so': File exists
	rm -f ${S}/lib/libpci.so
}

export PREFIX = "${prefix}"
export SBINDIR = "${sbindir}"
export SHAREDIR = "${datadir}"
export MANDIR = "${mandir}"

EXTRA_OEMAKE += "${PCI_CONF_FLAG}"

# The configure script breaks if the HOST variable is set
HOST[unexport] = "1"

do_install () {
	oe_runmake DESTDIR=${D} install install-lib

	install -d ${D}${bindir}
	ln -s ../sbin/lspci ${D}${bindir}/lspci
}

PACKAGES =+ "pciutils-ids libpci libpci-dev libpci-dbg"
FILES_pciutils-ids = "${datadir}/pci.ids*"
FILES_libpci = "${libdir}/libpci.so.*"
FILES_libpci-dbg = "${libdir}/.debug"
FILES_libpci-dev = "${libdir}/libpci.a ${libdir}/libpci.la ${libdir}/libpci.so \
                    ${includedir}/pci ${libdir}/pkgconfig"
