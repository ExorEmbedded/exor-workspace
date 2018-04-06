PAM_MODULE_VERSION = "1.5.1"

FILESEXTRAPATHS := "${THISDIR}/files"

SRC_URI += "https://github.com/sto/ngx_http_auth_pam_module/archive/v${PAM_MODULE_VERSION}.tar.gz;name=ngx_http_auth_pam_module"
SRC_URI[ngx_http_auth_pam_module.md5sum] = "1e0bbd4535386970d63f51064626bc9a"
SRC_URI[ngx_http_auth_pam_module.sha256sum] = "77676842919134af88a7b4bfca4470223e3a00d287d17c0dbdc9a114a685b6e7"
SRC_URI += "file://nginx.conf"
SRC_URI += "file://pam-nginx"
SRC_URI += "file://nginx.init"
SRC_URI += "file://security-remove-server-header.patch"

PR := "${PR}.x14"

INITSCRIPT_PARAMS = '${@base_contains("MACHINE_FEATURES", "fastboot", "defaults 70 69", "defaults 31 69",d)}'

do_configure () {

    if [ "${SITEINFO_BITS}" = "64" ]; then
        PTRSIZE=8
    else
        PTRSIZE=4
    fi

    echo $CFLAGS
    echo $LDFLAGS

    ./configure \
            --crossbuild=Linux:${TUNE_ARCH} \
            --with-endian=${@base_conditional('SITEINFO_ENDIANNESS', 'le', 'little', 'big', d)} \
            --with-int=4 \
            --with-long=${PTRSIZE} \
            --with-long-long=8 \
            --with-ptr-size=${PTRSIZE} \
            --with-sig-atomic-t=${PTRSIZE} \
            --with-size-t=${PTRSIZE} \
            --with-off-t=${PTRSIZE} \
            --with-time-t=${PTRSIZE} \
            --with-sys-nerr=132 \
            --conf-path=${sysconfdir}/nginx/nginx.conf \
            --http-log-path=${localstatedir}/log/nginx/access.log \
            --error-log-path=${localstatedir}/log/nginx/error.log \
            --pid-path=/run/nginx/nginx.pid \
            --prefix=${prefix} \
            --with-http_ssl_module \
            --with-http_gzip_static_module \
            --add-module=${WORKDIR}/ngx_http_auth_pam_module-${PAM_MODULE_VERSION}

}

do_install_append () {

    mkdir "${D}/${sysconfdir}/pam.d/"
    install -m 0644 "${WORKDIR}/pam-nginx" "${D}/${sysconfdir}/pam.d/nginx"
}

