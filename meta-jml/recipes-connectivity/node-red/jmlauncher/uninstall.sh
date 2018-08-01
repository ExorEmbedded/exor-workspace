#!/bin/sh

export PATH="/bin:/sbin:/usr/bin:/usr/sbin"

rm -rf "/home/$(whoami)/.node-red"
sync

echo "Node-Red uninstall: done" | logger
