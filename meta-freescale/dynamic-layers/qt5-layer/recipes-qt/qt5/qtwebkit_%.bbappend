CFLAGS = " \
    -DLINUX \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '-DEGL_API_FB -DEGL_API_WL', '', d)} \
"

CPPFLAGS = " \
    -DLINUX \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '-DEGL_API_FB -DEGL_API_WL', '', d)} \
"

CXXFLAGS = " \
    -DLINUX \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '-DEGL_API_FB -DEGL_API_WL', '', d)} \
"

