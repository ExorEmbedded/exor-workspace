#@TYPE: Machine

require conf/machine/include/imx-base.inc
require conf/machine/include/tune-cortexa9.inc
require conf/machine/include/soc-family.inc
require exor.inc

# Identify the machine as imx6q also for the dual lite. Differencies
# are only in uboot and kernel, we will deal with these in another way
SOC_FAMILY = "mx6:mx6q:"

# Make sure we install both imx6q and imx6d firmware
MACHINE_FIRMWARE_append = " firmware-imx-vpu-imx6d firmware-imx-epdc"

SERIAL_DEV = "ttymxc"

SERIAL_CONSOLE = "115200 ${SERIAL_DEV}1"

PREFERRED_PROVIDER_virtual/bootloader = "bootloader-imx6d"

PREFERRED_PROVIDER_virtual/kernel = "linux-imx-rt"
PREFERRED_PROVIDER_libfslparser = "libfslparser"
PREFERRED_PROVIDER_libfslcodec = "libfslcodec"
PREFERRED_PROVIDER_libfslvpuwrap = "libfslvpuwrap"
PREFERRED_RPROVIDER_gst1.0-fsl-plugin = "gst1.0-fsl-plugin"

PREFERRED_VERSION_linux-imx-rt = "3.14.28"
#PREFERRED_VERSION_firmware-imx = "3.14.28-1.0.0"

PREFERRED_PROVIDER_virtual/wayland-egl = "imx-gpu-viv"
PREFERRED_VERSION_imx-gpu-viv = "5.0.11.p4.4-hfp"
PREFERRED_VERSION_xf86-video-imxfb-vivante = "5.0.11.p4.4"
PREFERRED_VERSION_xf86-video-imxfb = "11.09.01"
PREFERRED_VERSION_gstreamer1.0-plugins-imx = "0.11.1"

ACCEPT_FSL_EULA = "1"
MACHINE_USES_VIVANTE_KERNEL_DRIVER_MODULE = "0"

MACHINEOVERRIDES =. "usom03:"
