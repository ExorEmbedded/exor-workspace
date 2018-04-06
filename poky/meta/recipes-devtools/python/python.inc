DESCRIPTION = "The Python Programming Language"
HOMEPAGE = "http://www.python.org"
LICENSE = "PSFv2"
SECTION = "devel/python"
# bump this on every change in contrib/python/generate-manifest-2.7.py
INC_PR = "r0"

LIC_FILES_CHKSUM = "file://LICENSE;md5=6b60258130e4ed10d3101517eb5b9385"

#SRC_URI = "http://www.python.org/ftp/python/${PV}/Python-${PV}.tar.bz2"
#SRC_URI[md5sum] = "c57477edd6d18bd9eeca2f21add73919"
#SRC_URI[sha256sum] = "726457e11cb153adc3f428aaf1901fc561a374c30e5e7da6742c0742a338663c"
SRC_URI = "http://www.python.org/ftp/python/${PV}/Python-${PV}.tgz"
SRC_URI[md5sum] = "17add4bf0ad0ec2f08e0cae6d205c700"
SRC_URI[sha256sum] = "a4f05a0720ce0fd92626f0278b6b433eee9a6173ddf2bced7957dfb599a5ece1"

PYTHON_MAJMIN = "2.7"

inherit autotools

PYTHONLSBOPTS = "--with-wctype-functions"
PYTHONLSBOPTS_linuxstdbase = "ac_cv_sizeof_off_t=8"

EXTRA_OECONF = "\
  --with-threads \
  --with-pymalloc \
  --with-cyclic-gc \
  --without-cxx \
  --with-signal-module \
  --enable-shared \
  --enable-ipv6=${@base_contains('DISTRO_FEATURES', 'ipv6', 'yes', 'no', d)} \
  ${PYTHONLSBOPTS} \
"
