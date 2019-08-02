DESCRIPTION = "Kernel driver for TI's Wl18xx"
LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/Proprietary;md5=0557f9d92cf58f2ccdd50f62f8ac0b28"

inherit module

BRANCH = "master"
SRC_URI = "git://git.ti.com/wilink8-wlan/build-utilites.git;protocol=git;branch=${BRANCH} \
           file://0001-fix-compiling.patch \
"

SRCREV = "${AUTOREV}"
S = "${WORKDIR}/git"

do_configure() {
    export ROOTFS="${S}/rootfs/"
    export KERNEL_PATH="${STAGING_KERNEL_DIR}"
    export KERNEL_VARIANT="DEFAULT"


    cd ${S}
    touch ${S}/setup-env
    mkdir -p  ${ROOTFS}/
    bash ${S}/build_wl18xx.sh init R8.7_SP3
}

do_compile() {
    export ROOTFS="${S}/rootfs/"
    export KERNEL_PATH="${STAGING_KERNEL_DIR}"
    export KERNEL_VARIANT="DEFAULT"
    unset CC

    cd ${S}
    bash ${S}/build_wl18xx.sh modules
	bash ${S}/build_wl18xx.sh firmware
}

do_install () {
    # install kernel modules
    install -d ${D}${base_libdir}/modules/${KERNEL_VERSION}/
    cp -r ${S}/rootfs/lib/modules/${KERNEL_VERSION}/* ${D}${base_libdir}/modules/${KERNEL_VERSION}/

    # install Firmware
    install -d ${D}${base_libdir}/firmware/
    cp -r ${S}/rootfs/lib/firmware/* ${D}${base_libdir}/firmware/
}
