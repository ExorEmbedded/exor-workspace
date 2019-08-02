inherit core-image-exorint-min

# Extra available IMAGE_FEATURES:
#
# - exorint-appliance           Appliance packages
#
FEATURE_PACKAGES_exorint-appliance = "packagegroup-exorint-appliance"

#
# graphical modules
#

IMAGE_FEATURES += "splash"
IMAGE_FEATURES += "qt4-x11-min"
IMAGE_FEATURES += "tools-debug"

IMAGE_INSTALL += "dbus"
IMAGE_INSTALL += "pointercal"
IMAGE_INSTALL += "metacity"
IMAGE_INSTALL += "formfactor"
IMAGE_INSTALL += "xterm"
IMAGE_INSTALL += "xev"
IMAGE_INSTALL += "xeyes"
IMAGE_INSTALL += "libx11-locale"
IMAGE_INSTALL += "tslib"
IMAGE_INSTALL += "winbind"
IMAGE_INSTALL += "ttf-arphic-uming"
IMAGE_INSTALL += "qt4-plugin-imageformat-gif"
IMAGE_INSTALL += "xscreensaver"
IMAGE_INSTALL += "xserver-xf86-config"
IMAGE_INSTALL += "cryptodev-module"
IMAGE_INSTALL += "htop"
IMAGE_INSTALL += "memtester"

# UserSpace bootloader manager
IMAGE_INSTALL_append_usom01 += "bootloader-env"
IMAGE_INSTALL_append_usom03 += "bootloader-imx6d-env"

# Check Touchscreen for eTop700/JSmart
IMAGE_INSTALL_append_us03-hsxx += "hsxx-checks"
IMAGE_INSTALL_append_us03-jsxx += "hsxx-checks"

# Vivante gpu driver for imx platforms
IMAGE_INSTALL_append_usom03 = " xf86-video-imxfb-vivante imx-gpu-viv"

do_image_wic[noexec] = "1"
