#!/bin/bash -e
#
# Break all packages of a given version (ALL FLAVOURS)

PROG="$(basename $0)"
VER=$1
if [ -z $VER ]; then
	echo "Usage: ${PROG} <version>"
	exit 1
fi

if ! echo $VER | grep -q "[0-9]\+\.[0-9]\+\.[0-9]\+" ; then
	echo "Version must be in X.Y.Z format!"
	exit 1
fi

echo "Marking all packages of version ${VER} as broken.."
find /home/autosvn/work/delivering/UN* -name *${VER}*.tar.gz -exec mv {} {}-broken \;
