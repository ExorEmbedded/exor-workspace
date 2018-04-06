DESCRIPTION = "U-Boot - the Universal Boot Loader"
HOMEPAGE = "http://www.denx.de/wiki/U-Boot/WebHome"
SECTION = "bootloaders"

inherit uboot-config deploy
inherit exorint-boottail
inherit exorint-version

# Set these to exclusively build only first or second stage
SPL_ONLY ?= "0"
UBOOT_ONLY ?= "0"

EXTRA_OEMAKE = 'CROSS_COMPILE=${TARGET_PREFIX} CC="${TARGET_PREFIX}gcc ${TOOLCHAIN_OPTIONS}"'

# Allow setting an additional version string that will be picked up by the
# u-boot build system and appended to the u-boot version.  If the .scmversion
# file already exists it will not be overwritten.
UBOOT_LOCALVERSION ?= ""

# Some versions of u-boot use .bin and others use .img.  By default use .bin
# but enable individual recipes to change this value.
UBOOT_SUFFIX ?= "bin"
UBOOT_IMAGE ?= "u-boot-${MACHINE}-${PV}-${PR}.${UBOOT_SUFFIX}"
UBOOT_BINARY ?= "u-boot.${UBOOT_SUFFIX}"
UBOOT_MAKE_TARGET ?= "all"

# Some versions of u-boot build an SPL (Second Program Loader) image that
# should be packaged along with the u-boot binary as well as placed in the
# deploy directory.  For those versions they can set the following variables
# to allow packaging the SPL.
SPL_BINARY ?= ""
SPL_IMAGE ?= "${SPL_BINARY}-${MACHINE}-${PV}-${PR}"

do_compile () {
	if [ "${@base_contains('DISTRO_FEATURES', 'ld-is-gold', 'ld-is-gold', '', d)}" = "ld-is-gold" ] ; then
		sed -i 's/$(CROSS_COMPILE)ld$/$(CROSS_COMPILE)ld.bfd/g' config.mk
	fi

	unset LDFLAGS
	unset CFLAGS
	unset CPPFLAGS

	if [ ! -e ${B}/.scmversion -a ! -e ${S}/.scmversion ]
	then
		echo ${UBOOT_LOCALVERSION} > ${B}/.scmversion
		echo ${UBOOT_LOCALVERSION} > ${S}/.scmversion
	fi

	oe_runmake ${UBOOT_MACHINE}
	oe_runmake ${UBOOT_MAKE_TARGET}

	oe_runmake env
}

do_install () {

    install -d ${D}/boot

    if [ "${UBOOT_ONLY}" = "1" ]; then
        install ${S}/${UBOOT_BINARY} ${D}/boot/${UBOOT_IMAGE}
        ln -sf ${UBOOT_IMAGE} ${D}/boot/${UBOOT_BINARY}
    elif [ "${SPL_ONLY}" = "1" ]; then
        install ${S}/${SPL_BINARY} ${D}/boot/${SPL_IMAGE}
        ln -sf ${SPL_IMAGE} ${D}/boot/${SPL_BINARY}
    fi

    if [ -e ${WORKDIR}/fw_env.config ] ; then
        install -d ${D}${sysconfdir}
        install -m 644 ${WORKDIR}/fw_env.config ${D}${sysconfdir}/fw_env.config
    fi
    install -d ${D}${bindir}
    install -m 755 ${S}/tools/env/fw_printenv ${D}${bindir}/fw_printenv
    install -m 755 ${S}/tools/env/fw_printenv ${D}${bindir}/fw_setenv
}


INSANE_SKIP_${PN} = "already-stripped"
PACKAGES =+ "${PN}-env"
FILES_${PN}-env = "${bindir}/fw_setenv ${bindir}/fw_printenv ${sysconfdir}/fw_env.config"

FILES_${PN} = "/boot ${sysconfdir} "
FILESPATH =. "${FILE_DIRNAME}/u-boot-git/${MACHINE}:"

do_deploy () {
    install -d ${DEPLOYDIR}

    if [ "${UBOOT_ONLY}" = "1" ]; then
        install ${S}/${UBOOT_BINARY} ${DEPLOYDIR}

        cd ${DEPLOYDIR}
        tar czvf ${VERSION_HUMAN}.tar.gz ${UBOOT_BINARY}
        ln -sf ${VERSION_HUMAN}.tar.gz ${VERSION_HUMAN_NOVER}.tar.gz
        rm ${UBOOT_BINARY}

    elif [ "${SPL_ONLY}" = "1" ]; then
        install ${S}/${SPL_BINARY} ${DEPLOYDIR}

        cd ${DEPLOYDIR}
        tar czvf ${VERSION_HUMAN}.tar.gz ${SPL_BINARY}
        ln -sf ${VERSION_HUMAN}.tar.gz ${VERSION_HUMAN_NOVER}.tar.gz
        rm ${SPL_BINARY}

    fi
}

addtask deploy before do_build after do_compile
addtask boot_tail before do_deploy after do_compile
