DEPENDS += "zip-native"

PKG_NAME ?= "${PN}"
PKG_VERSION ?= "${PV}"
PKG_INST_FOLDER ?= "${@d.getVar("PKG_NAME").lower()}"

inherit deploy
inherit nopackages

# These file should be provided by recipes
SRC_URI += " \
	file://run.sh \
	file://stop.sh \
	file://install.sh \
	file://uninstall.sh \
	file://update.sh \
	file://start.sh \
"

do_install() {

	install -d "${D}"
	install -d "${D}/deploy"

	for jmlScript in run.sh stop.sh install.sh uninstall.sh update.sh ; do
		install ${WORKDIR}/$jmlScript ${D} || bberror "Cannot find required script: $f"
	done

	install ${WORKDIR}/start.sh ${D}/deploy || bberror "Cannot find required script: start.sh"

        [ -e ${WORKDIR}/license.html ] && install ${WORKDIR}/license.html ${D}

	cat > ${D}/package.info << EOF
<jmlauncher>
<package>
  <name>${PKG_NAME}</name>
  <installationFolder>${PKG_INST_FOLDER}</installationFolder>
  <version>${PKG_VERSION}</version>
</package>
</jmlauncher>
EOF

	# Add dependency libs
	if [ -n "${PKG_LIBS}" ]; then
		install -d "${D}/deploy/lib"

		for f in ${PKG_LIBS}; do
			if [ -f "${STAGING_LIBDIR}/$f" ]; then
				install $( readlink -f "${STAGING_LIBDIR}/$f" ) ${D}/deploy/lib/$f
			else
				bberror "Cannot resolve dependency: $f"
			fi
		done
	fi
}

# Creates the jmulaucher package
do_deploy() {

	install -d "${DEPLOYDIR}/.tmppackage"
	cp -a ${D}/. ${DEPLOYDIR}/.tmppackage/

	pkgFileName="${PKG_NAME}-${PKG_VERSION}.zip"
	[ -n "${PKG_PLATFORM}" ] && pkgFileName="${PKG_PLATFORM}-$pkgFileName"
	pkgFileName="$( echo ${pkgFileName} | tr '[:upper:]' '[:lower:]' )"

	rm -rf ${DEPLOYDIR}/*.zip

	cd ${DEPLOYDIR}/.tmppackage
	zip -9 -y -r -q ../$pkgFileName *
	cd ..
	rm -rf .tmppackage
}

addtask deploy after do_install
deltask do_populate_sysroot
