require xorg-driver-common.inc

DEPENDS =+ "renderproto videoproto xextproto fontsproto"

python add_xorg_abi_depends() {
    _add_xorg_abi_depends(d, "video")
}
PACKAGEFUNCS =+ "add_xorg_abi_depends"

FILES_${PN}-dbg += " ${libdir}/xorg/modules/drivers/.debug/*"
