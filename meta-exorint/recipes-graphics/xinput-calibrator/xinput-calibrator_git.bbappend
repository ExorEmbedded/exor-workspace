FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PV = "0.7.5+git${SRCPV}"
PR := "${PR}.x0"

SRCREV = "14a682d8a56ac6c3c660dac1d3001dc46d252255"
SRC_URI = "git://github.com/jefflasslett/xinput_calibrator.git \
           file://30xinput_calibrate.sh \
           file://0001-xinput_calibrator_pointercal.sh-calfile-in-factory.patch \
           file://0002-xinput_calibrator_pointercal.sh-add-restore-option.patch"

