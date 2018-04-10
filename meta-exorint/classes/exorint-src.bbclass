# Exorint Provider for centralized source retrieval
#
# Inputs:
#   SRCNAME: name of source package
#   SRCEXT: extention of source package or repo
#   SRCSCHEME: scheme of URI
#   SRCUSER: login user
#   SRCHOST: target host - if undefined defaults primary repo, or secondary if SRCREPO="secondary"
#       primary = unfuddle
#       secondary = bitbucket
#   SRCLOC: location/base URI of source package
#   SRCSECTION: directory where package is found
#   SRCPROTO: source access protocol
#   SRCBRANCH: optional branch (defaults to master)
#
# See default values below.

SRCNAME ?= "${BPN}"
SRCEXT ?= ".git"
SRCSCHEME ?= "git"
SRCUSER ?= "git"
SRCHOST ?= '${@base_conditional(                            \
                "SRCREPO", "secondary", "bitbucket.org",    \
                "exorint.unfuddle.com", d)}'
SRCLOC ?= "${SRCSCHEME}://${SRCUSER}@${SRCHOST}"
SRCSECTION ?= "exorint"
SRCPROTO ?= "ssh"
SRCBRANCH ?= ""

SRC_URI = "${SRCLOC}/${SRCSECTION}/${SRCNAME}${SRCEXT}"
SRC_URI .= ";protocol=${SRCPROTO}"
SRC_URI .= '${@base_conditional("SRCBRANCH", "", "", ";branch=${SRCBRANCH}", d)}'

S = "${WORKDIR}/git"
