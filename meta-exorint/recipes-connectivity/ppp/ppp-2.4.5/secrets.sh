#!/bin/sh

AUTH_USER=`sys_params services/mobile/auth/user 2>/dev/null`
AUTH_PASS=`sys_params services/mobile/auth/pass 2>/dev/null`

err() {
    sys_params -V -w services/mobile/error $1
    exit 1
}

# Mobile error 500 = BADCREDENTIALS
[ -z "${AUTH_USER}" ] && err 500
[ -z "${AUTH_PASS}" ] && err 500

cat << EOF
# client    server    secret    IP addresses
${AUTH_USER}    *    ${AUTH_PASS}
EOF

exit 0
