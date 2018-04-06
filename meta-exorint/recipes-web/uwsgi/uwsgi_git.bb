DESCRIPTION = "An unladen web framework for building APIs and app backends."
HOMEPAGE = "http://projects.unbit.it/uwsgi/"
SECTION = "net"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=33ab1ce13e2312dddfad07f97f66321f"

PR = "r0"

SRCNAME = "uwsgi"
SRC_URI = "git://github.com/unbit/uwsgi.git"
SRCREV = "7604c6701809602804e3961f7fdb201049b8c993"
PV = "2.0.4+git${SRCPV}"
S = "${WORKDIR}/git"

inherit setuptools

INSANE_SKIP_${PN} += "rpaths"
