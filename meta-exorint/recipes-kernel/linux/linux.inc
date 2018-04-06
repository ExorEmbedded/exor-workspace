PV = "${KERNEL_RELEASE}+gitr${SRCPV}"
S = "${WORKDIR}/git"

KERNEL_IMAGETYPE = "zImage"
KERNEL_EXTRA_ARGS = "dtbs"

#inherit exorint-src
inherit exorint-version
inherit kernel
require version.inc

DTB_PATH = "${B}/arch/${ARCH}/boot/dts/"

do_configure() {
    if [ "x${KERNEL_MACHINE}" != "x" ]; then
        oe_runmake ${KERNEL_MACHINE}_defconfig ARCH=$ARCH
    else
        oe_runmake defconfig ARCH=$ARCH
    fi
}

do_install_append() {
    install -d "${D}/boot"
    for DTB in ${KERNEL_DEVICETREE}; do
        install -m 0644 ${DTB_PATH}/${DTB} "${D}/boot"
    done
}

do_deploy() {
    install -d "${DEPLOYDIR}"
    install -m 0644 "${B}/${KERNEL_OUTPUT}" "${DEPLOYDIR}"
    for DTB in ${KERNEL_DEVICETREE}; do
        install -m 0644 ${DTB_PATH}/${DTB} "${DEPLOYDIR}"
    done

    cd "${DEPLOYDIR}"
    tar czvf "${VERSION_HUMAN}.tar.gz" "${KERNEL_IMAGETYPE}" *.dtb
    ln -sf ${VERSION_HUMAN}.tar.gz ${VERSION_HUMAN_NOVER}.tar.gz

    rm "${KERNEL_IMAGETYPE}"
    rm *.dtb
}

PACKAGES_EXCLUDE = "kernel-vmlinux"

FILES_kernel-image += "/boot/*.dtb"

# FIX '$<50>ERROR: QA Issue: non debug package contains .debug directory: kernel-dev path /work/usom-poky-linux-gnueabi/linux/3.12.17+gitrAUTOINC+7993edfe50-rK0.0.2/packages-split/kernel-dev/usr/src/kernel/exorintos/files/.debug/vmlinux'
INSANE_SKIP_kernel-dev += "debug-files"

# FIX '$<50>ERROR: QA Issue: linux: Files/directories were installed but not shipped - /usr/src/debug [..]'
PACKAGES += "kernel-dbg"
FILES_kernel-dbg += "/usr/src/debug/*"
