FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PV = "0.7.5+git${SRCPV}"
PR := "${PR}.x6"

SRCREV = "14a682d8a56ac6c3c660dac1d3001dc46d252255"
SRC_URI = "git://github.com/jefflasslett/xinput_calibrator.git \
           file://0001-xinput_calibrator_pointercal.sh-calfile-in-factory.patch \
           file://0002-xinput_calibrator_pointercal.sh-add-restore-option.patch \
           file://30xinput_calibrate.sh \
"

#file://0003-Reduced-misclick-threshold.patch
#file://0001-calibration-improvement-with-average-of-10-coord.patch
#file://0002-Better-gui-feedback.patch
#file://0003-Fixed-portrait-mode-gui-bug.patch

SRC_URI_append_us03-jsxx = " file://xinput_calibrator_pointercal_exor.sh"

SRC_URI_append_us01-ca16 = " file://0004-calibration-input-device-selection.patch"

PACKAGE_ARCH= "${MACHINE_ARCH}"

RDEPENDS_${PN} += "bash"

do_install_append_us03-jsxx() {
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/xinput_calibrator_pointercal_exor.sh ${D}${bindir}/xinput_calibrator_once.sh
}

do_install_append() {
    rm ${D}${sysconfdir}/X11/Xsession.d/30xinput_calibrate.sh
}
