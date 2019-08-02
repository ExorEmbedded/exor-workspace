FILESEXTRAPATHS_prepend := "${THISDIR}/files/jmlauncher:"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

SRCNAME = "chrome-ext"
SRCBRANCH = "chromium64"
SRCREV = "46f336cfc493222507aa664cfcced829c6eeceac"

PV = "0.12"
PKG_NAME = "Chromium"
PKG_VERSION = "65-${PV}"
PKG_PLATFORM = "un6x"

inherit exorint-src
inherit jml-package

DEPENDS += "chromium-x11 epad"

# Some of the libraries needed by chromium are already included in the BSP, this
# is the list of those that are not and have to be included in the jmlauncher package. 
PKG_LIBS = " \
	libsmime3.so \
	libnss3.so \
	libnssutil3.so \
	libnspr4.so \
	libXss.so.1 \
	libplc4.so \
	libplds4.so \
	libsoftokn3.so \
	libnssdbm3.so \
	libnssutil3.so \
	libnssckbi.so \
	libfreebl3.so \
	libfreeblpriv3.so \
	libasound.so.2 \
	libwebpdemux.so.2 \
	libwebpmux.so.3 \
	libwebp.so.7 \
	libxslt.so.1 \
	libwebp.so.7 \
	libsmime3.so \
"

# These are only needed for BSP 1.0.x compatibility
PKG_LIBS += "libjpeg.so.62 libstdc++.so.6 libdbus-1.so.3"

do_install_append() {

        # GTK IM module
        install "${STAGING_LIBDIR}/gtk-2.0/2.10.0/immodules/libgtk-im.so" ${D}/deploy/

	install -m 0744 "${STAGING_LIBDIR}/chromium/chromium-bin" ${D}/deploy

        # Chromium *.pak files
        for f in content_resources.pak icudtl.dat keyboard_resources.pak chrome_100_percent.pak chrome_200_percent.pak resources.pak \
                 chrome_material_100_percent.pak locales/en-US.pak chromium-wrapper natives_blob.bin snapshot_blob.bin; do
                if [ -f "${STAGING_LIBDIR}/chromium/$f" ]; then
                        install -Dm 0644 "${STAGING_LIBDIR}/chromium/$f" ${D}/deploy/$f
                fi
        done

	install -d "${D}/deploy/ext"

	# Install extension
	for f in $( ls ${S} ); do
		install ${S}/$f ${D}/deploy/ext/$f
	done
}
