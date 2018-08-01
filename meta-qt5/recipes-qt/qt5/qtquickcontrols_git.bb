require qt5.inc
require qt5-git.inc

LICENSE = "GFDL-1.3 & BSD & ( GPL-3.0 & The-Qt-Company-GPL-Exception-1.0 | The-Qt-Company-Commercial ) & ( GPL-2.0+ | LGPL-3.0 | The-Qt-Company-Commercial )"
LIC_FILES_CHKSUM = " \
    file://LICENSE.LGPL3;md5=e6a600fd5e1d9cbde2d983680233ad02 \
    file://LICENSE.LGPLv3;md5=e0459b45c5c4840b353141a8bbed91f0 \
    file://LICENSE.GPL2;md5=b234ee4d69f5fce4486a80fdaf4a4263 \
    file://LICENSE.GPL3;md5=d32239bcb673463ab874e80d47fae504 \
    file://LICENSE.GPL3-EXCEPT;md5=763d8c535a234d9a3fb682c7ecb6c073 \
    file://LICENSE.GPLv2;md5=c96076271561b0e3785dad260634eaa8 \
    file://LICENSE.GPLv3;md5=88e2b9117e6be406b5ed6ee4ca99a705 \
    file://LICENSE.FDL;md5=6d9f2a9af4c8b8c3c769f6cc1b6aaf7e \
"

DEPENDS += "qtdeclarative"

RDEPENDS_${PN}-dev = ""

FILES_${PN}-qmlplugins += " \
  ${OE_QMAKE_PATH_QML}/QtQuick/Controls/Shaders \
  ${OE_QMAKE_PATH_QML}/QtQuick/Dialogs/qml/icons.ttf \
"

# Patches from https://github.com/meta-qt5/qtquickcontrols/commits/b5.9
# 5.9.meta-qt5.4
SRC_URI += " \
    file://0001-texteditor-fix-invalid-use-of-incomplete-type-class-.patch \
"

SRCREV = "8da20ddef88cb48b7bb09ff7dc1db6517add8e72"
