inherit core-image-exorint-min

# Extra available IMAGE_FEATURES:
#
# - exorint-appliance           Appliance packages
#
PACKAGE_GROUP_exorint-appliance = "packagegroup-exorint-appliance"

#
# graphical modules
#

IMAGE_FEATURES += "splash"
IMAGE_FEATURES += "qt4-x11-min"

IMAGE_INSTALL += "dbus"
IMAGE_INSTALL += "pointercal"
IMAGE_INSTALL += "metacity"
IMAGE_INSTALL += "formfactor"
IMAGE_INSTALL += "xterm"
IMAGE_INSTALL += "xev"
IMAGE_INSTALL += "xeyes"
IMAGE_INSTALL += "tslib"
IMAGE_INSTALL += "ttf-arphic-uming"
IMAGE_INSTALL += "qt4-plugin-imageformat-gif"
IMAGE_INSTALL += "libwinbind"
IMAGE_INSTALL += "xscreensaver"
IMAGE_INSTALL += "htop"
IMAGE_INSTALL += "memtester"
#IMAGE_INSTALL += "ibtp"

# UserSpace bootloader manager
IMAGE_INSTALL_append_usom01 += "bootloader-env"
IMAGE_INSTALL_append_usom03 += "bootloader-imx6d-env"

# Check Touchscreen for eTop700
IMAGE_INSTALL_append_us03-hsxx += "hsxx-checks"
