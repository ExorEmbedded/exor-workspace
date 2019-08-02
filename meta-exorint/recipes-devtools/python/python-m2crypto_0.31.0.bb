HOMEPAGE = "http://chandlerproject.org/bin/view/Projects/MeTooCrypto"
SUMMARY = "A Python crypto and SSL toolkit"
DESCRIPTION = "\
  M2Crypto is the most complete Python wrapper for OpenSSL featuring RSA, \
  DSA, DH, EC, HMACs, message digests, symmetric ciphers (including \
  AES); SSL functionality to implement clients and servers; HTTPS \
  extensions to Python's httplib, urllib, and xmlrpclib; unforgeable \
  HMAC'ing AuthCookies for web session management; FTP/TLS client and \
  server; S/MIME; ZServerSSL: A HTTPS server for Zope and ZSmime: An \
  S/MIME messenger for Zope. M2Crypto can also be used to provide SSL \
  for Twisted. \
  "
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://PKG-INFO;md5=1a788587f31a1c4b1c4dcb48424f2f0b"

PYPI_PACKAGE = "M2Crypto"

SRC_URI[md5sum] = "e717c40d561035c651e92d9cfd73fb84"
SRC_URI[sha256sum] = "fd59a9705275d609948005f4cbcaf25f28a4271308237eb166169528692ce498"

DEFAULT_PREFERENCE = "-1"

inherit setuptools pypi

DEPENDS += "openssl swig-native python-typing"

DISTUTILS_BUILD_ARGS += "build_ext -I${STAGING_INCDIR}"

inherit setuptools pypi

SWIG_FEATURES_x86-64 = "-D__x86_64__"
SWIG_FEATURES ?= ""
export SWIG_FEATURES

# Get around a problem with swig, but only if the
# multilib header file exists.
#
do_compile_prepend() {
	sed -i -e 's/self.add_multiarch_paths.*$/# &/;'  ${S}/setup.py
	sed -i -e 's/opensslIncludeDir = .*$/opensslIncludeDir = os.getenv("STAGING_INCDIR")/;'  ${S}/setup.py
	sed -i -e 's/opensslLibraryDir = .*$/opensslLibraryDir = os.getenv("STAGING_LIBDIR")/;'  ${S}/setup.py

	if [ "${SITEINFO_BITS}" = "64" ];then
		bit="64"
	else
		bit="32"
	fi

	if [ -e ${STAGING_INCDIR}/openssl/opensslconf-${bit}.h ]; then
		for i in SWIG/_ec.i SWIG/_evp.i; do
			sed -i -e "s/opensslconf.*\./opensslconf-${bit}\./" "$i"
		done
	elif [ -e ${STAGING_INCDIR}/openssl/opensslconf-n${bit}.h ] ;then
		for i in SWIG/_ec.i SWIG/_evp.i; do
			sed -i -e "s/opensslconf.*\./opensslconf-n${bit}\./" "$i"
		done
	fi
}

BBCLASSEXTEND = "native"
