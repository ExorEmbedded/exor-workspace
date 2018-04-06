#
# Note: this file adds core system utilities only. See packagegroups for proprietary components.
#

inherit core-image
inherit distro_features_check
inherit extrausers

# Extra available IMAGE_FEATURES:
#
# - qt4-x11-min                 Qt4 X11 minimal packages
# - exorint-appliance-min       Minimal appliance packages
#
PACKAGE_GROUP_qt4-x11-min = "packagegroup-qt-x11-min"
PACKAGE_GROUP_exorint-appliance-min = "packagegroup-exorint-appliance-min"

#
# features/packages
#

IMAGE_FEATURES = ""
IMAGE_FEATURES += "package-management"
IMAGE_FEATURES += "tools-debug"
IMAGE_FEATURES += "read-only-rootfs"

# core
IMAGE_INSTALL = ""
IMAGE_INSTALL += "bc"
IMAGE_INSTALL += "cronie"
IMAGE_INSTALL += "kernel-modules"
IMAGE_INSTALL += "kernel-module-tun"
IMAGE_INSTALL += "logrotate"
IMAGE_INSTALL += "ntp"
IMAGE_INSTALL += "ntp-utils"
IMAGE_INSTALL += "packagegroup-core-boot"
IMAGE_INSTALL += "packagegroup-base-extended"
IMAGE_INSTALL += "sudo"
IMAGE_INSTALL += "tzdata"
IMAGE_INSTALL += "tzdata-posix"
IMAGE_INSTALL += "util-linux"
IMAGE_INSTALL += "iproute2"
IMAGE_INSTALL += "openssl-backcompat"

# devices
IMAGE_INSTALL += "mtd-utils"
IMAGE_INSTALL += "usbutils"
IMAGE_INSTALL += "pciutils"
IMAGE_INSTALL += "i2c-tools"
IMAGE_INSTALL += "setserial"
IMAGE_INSTALL += "minicom"

# filesystem
IMAGE_INSTALL += "elfutils"
IMAGE_INSTALL += "e2fsprogs-e2fsck"
IMAGE_INSTALL += "e2fsprogs-mke2fs"
IMAGE_INSTALL += "e2fsprogs-tune2fs"
IMAGE_INSTALL += "dosfstools"
IMAGE_INSTALL += "quota"

# networking
IMAGE_INSTALL += "avahi-autoipd"
IMAGE_INSTALL += "avahi-daemon"
IMAGE_INSTALL += "avahi-utils"
IMAGE_INSTALL += "bridge-utils"
IMAGE_INSTALL += "curl"
IMAGE_INSTALL += "ethtool"
IMAGE_INSTALL += "ifplugd"
IMAGE_INSTALL += "iputils"
IMAGE_INSTALL += "iptables"
IMAGE_INSTALL += "lsof"
IMAGE_INSTALL += "net-tools"
IMAGE_INSTALL += "netcat-openbsd"
IMAGE_INSTALL += "netkit-ftp"
IMAGE_INSTALL += "portmap"
IMAGE_INSTALL += "ppp"
IMAGE_INSTALL += "rsync"
IMAGE_INSTALL += "openssh-sshd"
IMAGE_INSTALL += "openssh-ssh"
IMAGE_INSTALL += "openssh-scp"
IMAGE_INSTALL += "openssh-sftp-server"
IMAGE_INSTALL += "openvpn"
IMAGE_INSTALL += "tcpdump"

# networking/wifi
IMAGE_INSTALL += "iw"
IMAGE_INSTALL += "wpa-supplicant"
IMAGE_INSTALL += "wpa-supplicant-cli"

# monitoring
IMAGE_INSTALL += "net-snmp-server"

# development
IMAGE_INSTALL += "vim"
IMAGE_INSTALL += "nano"
IMAGE_INSTALL += "screen"
IMAGE_INSTALL += "diffutils"
#IMAGE_INSTALL += "memtester"
#IMAGE_INSTALL += "oprofile"

# the following require kernel tracing
#IMAGE_INSTALL += "lttng-tools"
#IMAGE_INSTALL += "lttng-modules"

# extended (Busybox lacks required features)
IMAGE_INSTALL += "gawk"
IMAGE_INSTALL += "grep"
IMAGE_INSTALL += "gzip"
IMAGE_INSTALL += "procps"
IMAGE_INSTALL += "sed"
IMAGE_INSTALL += "tar"
IMAGE_INSTALL += "wget"
IMAGE_INSTALL += "start-stop-daemon"

# Base x11/vnc support
IMAGE_INSTALL += "packagegroup-core-x11"
IMAGE_INSTALL += "xserver-xorg-xvfb"
IMAGE_INSTALL += "xsetroot"
IMAGE_INSTALL += "x11vnc"
IMAGE_INSTALL += "xwd"
IMAGE_INSTALL += "libsm"
IMAGE_INSTALL += "liberation-fonts"
IMAGE_INSTALL += "ttf-symbola"

# FastBoot recipes
#IMAGE_INSTALL += '${@base_contains("MACHINE_FEATURES", "fastboot", "fastboot-checks", "",d)}'
IMAGE_INSTALL += '${@base_contains("MACHINE_FEATURES", "fastboot", "fastboot-checks-prechecks", "",d)}'
IMAGE_INSTALL += '${@base_contains("MACHINE_FEATURES", "fastboot", "fastboot-checks-postchecks", "",d)}'
IMAGE_INSTALL_append_wu16      = " fastboot-checks-fastbootwu16"
IMAGE_INSTALL_append_us03-hsxx = " fastboot-checks-fastbootwu16"
IMAGE_INSTALL_append_us01-hs07 = " fastboot-checks-fastbootwu16"
IMAGE_INSTALL_append_us01-au16 = " fastboot-checks-fastbootwu16"
IMAGE_INSTALL_append_wu16      = " fastboot-checks-fastbootx11"

#IMAGE_INSTALL += '${@base_contains("MACHINE_FEATURES", "fastboot", "xsplash", "",d)}'

# Kernel modules (out-of-tree)
IMAGE_INSTALL_append_ca16 = " kmod-wifi-rs9113"
IMAGE_INSTALL_append_jsxx = " kmod-wifi-rs9113-reset"
IMAGE_INSTALL_append_wu16 = " kmod-wifi-rs9113-reset"

# Tool for I210 flash programming on be15
IMAGE_INSTALL_append_be15 = " eepromARMTool"

# Firmware (e.g. wifi support)
IMAGE_INSTALL += "linux-firmware-rtl8192cu"

REQUIRED_DISTRO_FEATURES = "x11"

#
# users
#

# default root pass is same as username - can override in branding layer
DEFAULT_ROOT_HASH ?= "$6$Sia8giVO$2J32HysmlXNqoHmjLBQ1xFSg44TUkCzsXACur5DvvFM0o.ki6/3Eh6qvvM8eidt09s/aoqRsGGj5N6jTrpmMx0"

# revert behaviour of zap_root_password() in image.bbclass - set it to 'x' because all hashes are set in /etc/shadow
ROOTFS_POSTPROCESS_COMMAND += "\
    sed 's%^root:\*:%root:x:%' \
        < ${IMAGE_ROOTFS}/etc/passwd \
        > ${IMAGE_ROOTFS}/etc/passwd.new; \
    mv ${IMAGE_ROOTFS}/etc/passwd.new ${IMAGE_ROOTFS}/etc/passwd; \
"

# set root user hash
ROOTFS_POSTPROCESS_COMMAND += "\
    sed 's%^root:[^:]*:%root:${DEFAULT_ROOT_HASH}:%' \
        < ${IMAGE_ROOTFS}/etc/shadow \
        > ${IMAGE_ROOTFS}/etc/shadow.new; \
    mv ${IMAGE_ROOTFS}/etc/shadow.new ${IMAGE_ROOTFS}/etc/shadow; \
"

# hostname is set upon startup via /etc/init.d/hostname.sh
ROOTFS_POSTPROCESS_COMMAND += "rm ${IMAGE_ROOTFS}/etc/hostname;"

# revert read-only-rootfs logic in image.bbclass - our /etc is writable, so we write keys there
ROOTFS_POSTPROCESS_COMMAND += "rm ${IMAGE_ROOTFS}/etc/default/ssh;"

# override function from image.bbcalss. Prevent /etc/timestamp initialization
rootfs_update_timestamp () {
   :
}

# other system users - default password is same as username
# Note: escaping required here!
DEFAULT_ADMIN_HASH ?= "\$1\$rfrSHPq/\$/Zm7UP.8cLKqEwRY0kI3c1"
DEFAULT_USER_HASH ?= "\$1\$wo1/p2fw\$FXLqWuAo96HT5.tp5tNZS0"

EXTRA_USERS_PARAMS += "useradd -u 10000 -p '${DEFAULT_ADMIN_HASH}' admin;"
EXTRA_USERS_PARAMS += "useradd -u 20000 -p '${DEFAULT_USER_HASH}' user;"

# make sure shadow file has its own group (for PAM module access)
ROOTFS_POSTPROCESS_COMMAND += "chgrp shadow ${IMAGE_ROOTFS}/etc/shadow;"
ROOTFS_POSTPROCESS_COMMAND += "chmod 440 ${IMAGE_ROOTFS}/etc/shadow;"

# give www user access to shadow group for PAM authentication
EXTRA_USERS_PARAMS += "usermod -a -G shadow www;"

# all users have r/w perms on data partition
EXTRA_USERS_PARAMS += "groupadd data;"
EXTRA_USERS_PARAMS += "usermod -a -G data user;"
EXTRA_USERS_PARAMS += "usermod -a -G data admin;"
EXTRA_USERS_PARAMS += "usermod -a -G data www;"

# all users have r/w perms on serial, communication devices and video
EXTRA_USERS_PARAMS += "groupadd comm;"
EXTRA_USERS_PARAMS += "usermod -a -G comm user;"
EXTRA_USERS_PARAMS += "usermod -a -G comm admin;"
EXTRA_USERS_PARAMS += "usermod -a -G dialout user;"
EXTRA_USERS_PARAMS += "usermod -a -G dialout admin;"
EXTRA_USERS_PARAMS += "usermod -a -G video user;"
EXTRA_USERS_PARAMS += "usermod -a -G video admin;"
