SYSROOT_PREPROCESS_FUNCS += "extra_sysroot_preprocess"

extra_sysroot_preprocess () {
        sysroot_stage_dir ${D}${bindir} ${SYSROOT_DESTDIR}${bindir}
        sysroot_stage_dir ${D}${datadir} ${SYSROOT_DESTDIR}${datadir}
}
