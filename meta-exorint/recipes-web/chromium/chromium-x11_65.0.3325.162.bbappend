DEPENDS += "zip-native"
FILESEXTRAPATHS_prepend := "${THISDIR}/exor:"

SRC_URI += "file://0001-add-exor-extension-to-whitelist.patch \
	file://0002-sync-after-option-write.patch \
	file://0003-do-not-stop-extensions-on-reset.patch \
	file://0004-disable-alsa.patch \
	file://0005-ime-send-location-change-on-password-fields.patch \
	file://0006-always-resend-ime-focus-on-textarea.patch \
	file://0007-allow-extensions-terminate-browser.patch \
	file://0008-sync-on-localstorage-db-write.patch \
	file://0009-Enable-share-group-workaround-for-Vivante-GPUs.patch \
	file://0010-fix-gtk2-build.patch \
	file://0012-disable-sync-promo.patch \
	file://0013-disable-welcome-page.patch \
	file://0014-notify-ssl-errors-to-extensions.patch \
	file://0015-revert-removeDisableInfobars.patch \
"

SRC_URI += "file://ui-resources.patch \
	file://chrome-resources.patch \
"

PACKAGECONFIG = "use-egl impl-side-painting"

DEPENDS_remove = "pulseaudio"

EXTRA_OEGYP_prepend = "-Dbuildtype=Official \
	-Denable_prod_wallet_service=0 \
	-Dlinux_dump_symbols=0 \
	-Dfull_wpo_on_official=1 "

# Use gtk2
DEPENDS_remove = "gtk+3"
DEPENDS += "gtk+"
GN_ARGS += "use_gtk3=false"

do_install_append() {

	if [ -f "${B}/out/${CHROMIUM_BUILD_TYPE}/chrome_material_100_percent.pak" ]; then
		install -Dm 0644 ${B}/out/${CHROMIUM_BUILD_TYPE}/chrome_material_100_percent.pak ${D}${bindir}/${BPN}
	fi
}

sysroot_stage_all_append () {                                     
    sysroot_stage_dir ${D}${bindir}/chromium ${SYSROOT_DESTDIR}${bindir}/chromium
} 
