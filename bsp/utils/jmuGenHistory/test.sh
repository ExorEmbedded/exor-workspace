#!/bin/bash -xe

TMPDIR="${PWD}/tmp"
IMAGEDIR="${TMPDIR}/UN60_HSXX/linux-1.0.x/BSP/mainos/"

init ()
{
    cleanup
    mkdir -p "${IMAGEDIR}"
}

cleanup ()
{
    rm -rf "${TMPDIR}"
}

run ()
{
    pushd test-vp
    tar czvf "${IMAGEDIR}"/un60-hsxx-mainos-1.2.3.rootfs.tar.gz .
    popd

    pushd test-v
    tar czvf "${IMAGEDIR}"/un60-hsxx-mainos-1.2.4.rootfs.tar.gz .
    popd
   
    node ../jmuGenHistory.js gen -d "${TMPDIR}" -s "1.2.4" -n 1 -v
    node ../jmuGenHistory.js merge -d "${TMPDIR}" -v
}

init
run
#cleanup

exit 0
