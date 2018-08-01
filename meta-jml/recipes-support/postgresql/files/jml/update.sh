#!/bin/sh

dbus-send --print-reply --system --dest=com.exor.JMLauncher '/' com.exor.JMLauncher.updateFinished int32:0 string:""
