IMAGE_FSTYPES += "tar.gz"

MKUBIFS_ARGS = "-F -m 2048 -e 126976 -c 4095"
UBINIZE_ARGS = "-m 2048 -p 128KiB -s 512 -O 2048"
UBI_VOLNAME = "rootfs"

MACHINE_FEATURES = "serial rtc fastboot"
