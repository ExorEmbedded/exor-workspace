#!/bin/sh

cd $(dirname $0)
SCRIPTDIR=$(pwd)
echo $SCRIPTDIR

node red.js $@
