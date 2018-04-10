DEPENDS += "zip-native"

PKG_NAME ?= "${PN}"
PKG_VERSION ?= "${PV}"
PKG_INST_FOLDER ?= "${PKG_NAME}"

inherit deploy

# These file should be provided by recipes
SRC_URI += "file://start.sh \
        file://run.sh \
        file://stop.sh \
        file://install.sh \
        file://uninstall.sh \
        file://update.sh "

do_install() {

	install -d "${D}"
	install -d "${D}/deploy"

	for jmlScript in run.sh stop.sh install.sh uninstall.sh update.sh ; do
		install ${WORKDIR}/$jmlScript ${D} || bberror "Cannot find required script: $f"
	done

        [ -e ${WORKDIR}/license.html ] && install ${WORKDIR}/license.html ${D}

	install ${WORKDIR}/start.sh ${D}/deploy || bberror "Cannot find required script: start.sh"

	cat > ${D}/package.info << EOF
<jmlauncher>
<package>
  <name>${PKG_NAME}</name>
  <installationFolder>${PKG_INST_FOLDER}</installationFolder>
  <version>${PKG_VERSION}</version>
</package>
</jmlauncher>
EOF
}

# Creates the jmulaucher package
do_deploy() {

	install -d "${DEPLOYDIR}/.tmppackage"

	cp -a ${D}/. ${DEPLOYDIR}/.tmppackage/

	pkgFileName="${PKG_NAME}-${PKG_VERSION}.zip"
	[ -n "${PKG_PLATFORM}" ] && pkgFileName="${PKG_PLATFORM}-$pkgFileName"

	rm -rf ${DEPLOYDIR}/*.zip

	cd ${DEPLOYDIR}/.tmppackage
	zip -9 -y -r -q ../$pkgFileName *
	cd ..
	rm -rf .tmppackage
}

do_populate_sysroot[noexec] = "1"

FILES_${PN} += "/* /deploy/*"

addtask deploy after do_install
