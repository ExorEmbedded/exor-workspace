#!/bin/bash

if [ "$1" != "start" ]
then
	exit 0;
fi

. /etc/exorint.funcs

# trigger the sorted events
echo -e '\000\000\000\000' > /proc/sys/kernel/hotplug
/sbin/udevd -d
udevadm control --env=STARTUP=1
udevadm trigger --action=add \
        --subsystem-match=input \
        --subsystem-match=spi \
        --subsystem-match=tty \
        --subsystem-match=i2c \
        --subsystem-match=usb
udevadm trigger --action=change --property-match DRIVER=plxx_manager

ifconfig lo up

FACTORYTMPMNT="/mnt/factory/"
SSL_DIR="${FACTORYTMPMNT}/etc/ssl"
CERT="${SSL_DIR}/certs/ssl-cert-os.pem"
CSR="${SSL_DIR}/certs/ssl-cert-os.csr"
KEY="${SSL_DIR}/private/ssl-cert-os.key"
SSL_DIR_SYM="/etc/ssl"

if [ ! -f "${CERT}" ] || [ ! -f "${KEY}" ] || [ ! -f "${CSR}" ]; then
   echo "Generating SSL keypair..."

   mount -o remount,rw ${FACTORYTMPMNT}

   rm -rf "${SSL_DIR}" "${SSL_DIR_SYM}"
   mkdir -p "$( dirname $CERT )" "$( dirname $KEY )"

   HOSTNAME="$(hostname)"
   SUBJECT="/CN=${HOSTNAME}"

   SSL_CONFIG="/tmp/openssl.cnf"
   printf "distinguished_name = req_dn\n[req_dn]\n" >> "${SSL_CONFIG}"
   printf "[SAN]\nsubjectAltName=DNS:${HOSTNAME},DNS:${HOSTNAME}.local\n" >> "${SSL_CONFIG}"
   openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -sha512 \
      -subj "${SUBJECT}" \
      -config "${SSL_CONFIG}" \
      -extensions SAN \
      -keyout "${KEY}" -out "${CERT}"
   rm "${SSL_CONFIG}"

   openssl req -new -key "${KEY}" -sha512 -out "${CSR}" -subj "${SUBJECT}"

   chown -R root:root "${SSL_DIR}"
   chmod 600 "${KEY}" "${CERT}" "${CSR}"

   mount -o remount,ro ${FACTORYTMPMNT}

fi

if [ ! -L "${SSL_DIR_SYM}" ]; then
   rm -rf "${SSL_DIR_SYM}"
   ln -s "${SSL_DIR}" "${SSL_DIR_SYM}"
fi

# Blind device management
[ "$(exorint_ver_type)" = "ROUTER" ] &&  exorint_service_enable "router"
