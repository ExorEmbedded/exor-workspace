#!/bin/sh

cd $(dirname $0)

ln -sf postgres deploy/bin/postmaster

chown -R 28:28 deploy/bin
chown -R 28:28 deploy/lib
chown -R 28:28 deploy/share

sync

dbus-send --print-reply --system --dest=com.exor.JMLauncher '/' com.exor.JMLauncher.installFinished int32:0 string:""
