# Default root pass is 'exorint'

DEFAULT_ROOT_HASH = "$6$VnipYhm/$4CP05xBsuSItdw5E8O6wp9jwGYnMZUeaD7Ek7tAzOeRG4i//i72yv8bayNkfNZ5Hdd/lo3Pu5ZxWKPz7TV9R3."

ROOTFS_POSTPROCESS_COMMAND += "\
    mkdir ${IMAGE_ROOTFS}/lost+found; \
    echo ${VERSION} > ${IMAGE_ROOTFS}/boot/version; \
    echo ${EXOS_VERSION_TAG} > ${IMAGE_ROOTFS}/boot/version_tag; \
    find ${IMAGE_ROOTFS} | wc -l > ${IMAGE_ROOTFS}/files.count; \
"

# optimization: prepend files which need to be extracted in update preprocessing [bsp #244]
IMAGE_COMPRESS_PREPEND_FILES += "./files.count"
IMAGE_COMPRESS_PREPEND_FILES += "./boot/version"
# [ .. ] see mainos.inc
