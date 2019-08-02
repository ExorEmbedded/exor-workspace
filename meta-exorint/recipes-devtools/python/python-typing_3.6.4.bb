inherit setuptools
require python-typing.inc

SRC_URI = "https://github.com/python/typing/archive/${PV}.zip"

SRC_URI[md5sum] = "9af580be3d868f1c215e340e44fd424c"
SRC_URI[sha256sum] = "26b89a64eb956a81c51ffe693971bbafeb0d1aecb4f622f0f333c379d9be7e09"

S = "${WORKDIR}/typing-${PV}"
