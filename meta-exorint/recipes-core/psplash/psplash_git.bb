SUMMARY = "Userspace framebuffer boot logo based on usplash."
DESCRIPTION = "PSplash is a userspace graphical boot splash screen for mainly embedded Linux devices supporting a 16bpp or 32bpp framebuffer. It has few dependencies (just libc), supports basic images and text and handles rotation. Its visual look is configurable by basic source changes. Also included is a 'client' command utility for sending information to psplash such as boot progress information."
HOMEPAGE = "http://git.yoctoproject.org/cgit/cgit.cgi/psplash"
SECTION = "base"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://psplash.h;beginline=1;endline=16;md5=840fb2356b10a85bed78dd09dc7745c6"

PR = "r35"
SRCNAME = "ltools-${BPN}"
SRCBRANCH = "exorint-1.x.x"
SRCREV = "61aba02650c82af9262fa21f52a6b2de3ee26051"
SRC_URI = "git://github.com/ExorEmbedded/psplash.git;branch=${SRCBRANCH}"

inherit exorint-src

inherit autotools
inherit pkgconfig
#inherit update-rc.d

B = "${S}"

do_install_append() {
	install -d ${D}/mnt/.psplash/
	install -d ${D}/mnt/.splashimage/
}

FILES_${PN} += "/mnt/.psplash"
FILES_${PN} += "/mnt/.splashimage"
