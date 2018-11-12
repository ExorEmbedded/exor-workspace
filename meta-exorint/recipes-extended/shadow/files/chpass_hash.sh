#!/bin/sh -e
#
# Update password hashes in /mnt/factory/shadow

if [ $# -lt 2 ]; then
	echo "Missin arguments."
	echo "Usage: $0 <username> <SHA512 hash>"
	exit 1
fi

FACTORY_MNT="/mnt/factory/"
ETC_MNT="/etc/"
USER=$1
PASSW=$2

type="$( echo "$USER" | cut -d'$' -f2 )"
sha512="$( echo "$PASSW" | cut -d'$' -f4 )"
[ "$type" != "6" -o "${#sha512}" -ne 86 ] && echo "WARNING: Hash is not SHA512."

mount -o remount,rw "${FACTORY_MNT}"

rm "${ETC_MNT}shadow" || true
cp "${FACTORY_MNT}shadow" "${ETC_MNT}"
echo "${USER}:${PASSW}" | /usr/sbin/chpasswd -e
mv "${ETC_MNT}shadow" "${FACTORY_MNT}"
chgrp shadow "${FACTORY_MNT}shadow"
ln -sf "${FACTORY_MNT}shadow" "${ETC_MNT}shadow"
sync

mount -o remount,ro "${FACTORY_MNT}"

exit 0
