#!/bin/sh
dbus-send --print-reply --system --dest=com.exor.JMLauncher '/' com.exor.JMLauncher.installFinished int32:0 string:""
