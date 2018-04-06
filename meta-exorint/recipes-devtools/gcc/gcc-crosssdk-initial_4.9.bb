require recipes-devtools/gcc/gcc-cross-initial_${PV}.bb
require recipes-devtools/gcc/gcc-crosssdk-initial.inc

do_configure_prepend() {
   mkdir -p ${STAGING_DIR_TCBOOTSTRAP}
   ln -s ${STAGING_DIR_TCBOOTSTRAP}${SDKPATHNATIVE}/usr ${STAGING_DIR_TCBOOTSTRAP}/usr
   ln -s ${STAGING_DIR_TCBOOTSTRAP}${SDKPATHNATIVE}/lib ${STAGING_DIR_TCBOOTSTRAP}/lib
}
