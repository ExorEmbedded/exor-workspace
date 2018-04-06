# Add libpthread and libthread_db debug info to BSP

PACKAGES = "${PN} ${PN}-dbg catchsegv sln nscd ldd ${PN}-utils eglibc-thread-db ${PN}-pic libcidn libmemusage libsegfault ${PN}-pcprofile libsotruss eglibc-extra-nss ${PN}-dev ${PN}-staticdev ${PN}-doc"
libc_baselibs += "${base_libdir}/.debug/libpthread* ${base_libdir}/.debug/libthread_db*"
PACKAGEFUNCS_remove = "do_package_qa"
