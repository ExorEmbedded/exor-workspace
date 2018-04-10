PV = "${LINUX_VERSION}+git${SRCPV}"

KERNEL_IMAGETYPE = "zImage"
KERNEL_EXTRA_ARGS = "dtbs"
MODULE_TARBALL_DEPLOY = "0"

inherit kernel
inherit exorint-src
inherit exorint-version
require version.inc

DTB_PATH = "${B}/arch/${ARCH}/boot/dts/"

B = "${S}"

do_kernel_configme() {
    cp "${S}/arch/${ARCH}/configs/${KERNEL_MACHINE}_defconfig" "${B}/.config"
}

do_install_append() {
    install -d "${D}/boot"
    for DTB in ${KERNEL_DEVICETREE}; do
        install -m 0644 ${DTB_PATH}/${DTB} "${D}/boot"
    done
}

do_deploy() {
    install -d "${DEPLOYDIR}"

    install -m 0644 "${B}/${KERNEL_OUTPUT_DIR}/${KERNEL_IMAGETYPE}" "${DEPLOYDIR}"
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
#INSANE_SKIP_kernel-dev += "debug-files"

# FIX '$<50>ERROR: QA Issue: linux: Files/directories were installed but not shipped - /usr/src/debug [..]'
#PACKAGES += "kernel-dbg"
#FILES_kernel-dbg += "/usr/src/debug/*"

addtask kernel_configme before do_configure after do_patch

python () {
    # Avoid race conditions with do_unpack_and_patch task form the archiver class by specifying the correct order
    if bb.data.inherits_class('archiver', d):
        bb.build.addtask('do_kernel_configme', 'do_configure', 'do_unpack_and_patch', d)
}
