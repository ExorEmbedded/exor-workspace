#!/bin/sh

export PATH="/bin:/sbin:/usr/bin:/usr/sbin"

rm -rf "/home/$(whoami)/.pki"
sync

echo "Chromium uninstall: done" | logger
