# Exorint Provider for centralized source retrieval
#
# Inputs:
#   SRCNAME: name of source package
#   SRCEXT: extention of source package or repo
#   SRCSCHEME: scheme of URI
#   SRCUSER: login user
#   SRCHOST: target host - if undefined defaults primary repo (bitbucket)
#   SRCLOC: location/base URI of source package
#   SRCPROJECT: project to which the package belongs
#   SRCPROTO: source access protocol
#   SRCBRANCH: optional branch (defaults to master)
#
# See default values below.

SRCNAME ?= "${BPN}"
SRCEXT ?= ".git"
SRCSCHEME ?= "git"
SRCUSER ?= "git"
SRCHOST ?= "bitbucket.exorint.cloud"
SRCLOC ?= "${SRCSCHEME}://${SRCUSER}@${SRCHOST}"
SRCPROJECT ?= "bsp"
SRCPROTO ?= "ssh"
SRCBRANCH ?= ""

#SRC_URI = "${SRCLOC}/${SRCPROJECT}/${SRCNAME}${SRCEXT}"
#SRC_URI .= ";protocol=${SRCPROTO}"
#SRC_URI .= '${@base_conditional("SRCBRANCH", "", "", ";branch=${SRCBRANCH}", d)}'

S = "${WORKDIR}/git"
