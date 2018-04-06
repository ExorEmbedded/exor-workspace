require recipes-devtools/gcc/gcc-cross_${PV}.bb
require recipes-devtools/gcc/gcc-crosssdk.inc

do_configure_prepend() {
   mkdir -p ${STAGING_DIR_TARGET}
   ln -s ${STAGING_DIR_TARGET}${SDKPATHNATIVE}/usr ${STAGING_DIR_TARGET}/usr
   ln -s ${STAGING_DIR_TARGET}${SDKPATHNATIVE}/lib ${STAGING_DIR_TARGET}/lib

}
