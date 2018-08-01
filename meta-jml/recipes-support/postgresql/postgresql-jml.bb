FILESEXTRAPATHS_prepend := "${THISDIR}/files/jml:"

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://COPYRIGHT;md5=81b69ddb31a8be66baafd14a90146ee2"

PV = "0.1"
PKG_NAME = "postgresql"
PKG_VERSION = "9.4-${PV}"
PKG_PLATFORM = "un6x"

DEPENDS += "postgresql"

inherit jml-package

SRC_URI += "file://COPYRIGHT \
	file://service.sh \
"

S = "${WORKDIR}"

do_install_append() {

	mkdir -p ${D}/deploy/bin

	for bin in clusterdb createuser dropuser pgbench pg_ctl pg_isready pg_resetxlog pg_test_fsync pg_xlogdump pltcl_loadmod postmaster vacuumdb \
		createdb dropdb ecpg pg_archivecleanup pg_config pg_dump pg_receivexlog pg_restore pg_test_timing pltcl_delmod postgres psql vacuumlo \
		createlang droplang initdb pg_basebackup pg_controldata pg_dumpall pg_recvlogical pg_standby pg_upgrade pltcl_listmod postgresql-setup reindexdb; do

		cp -a ${STAGING_BINDIR}/$bin ${D}/deploy/bin
	done

	mkdir -p ${D}/deploy/lib
	cp -rL ${STAGING_LIBDIR}/libpq.so.5 ${STAGING_LIBDIR}/postgresql ${D}/deploy/lib

	mkdir -p ${D}/deploy/share
	cp -r ${STAGING_DATADIR}/postgresql ${D}/deploy/share

	cp ${WORKDIR}/service.sh ${D}/deploy/
}

FILES_${PN}-dbg += "deploy/bin/.debug/*	\
	deploy/lib/.debug/* \
	deploy/lib/postgresql/.debug/* \
	deploy/lib/postgresql/pgxs/src/test/regress/.debug/* \
"
