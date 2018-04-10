#!/bin/sh

SCRIPT_DIR="$( dirname $0 )"
DEPLOY_DIR="$( readlink -f ${SCRIPT_DIR} )/deploy"

echo "\"${DEPLOY_DIR}/libgtk-im.so\"" > $DEPLOY_DIR/gtk.immodules
echo '"epad-im-invoker" "EPAD VKeyboard" "" "" "*"' >> $DEPLOY_DIR/gtk.immodules

dbus-send --print-reply --system --dest=com.exor.JMLauncher '/' com.exor.JMLauncher.installFinished int32:0 string:""
