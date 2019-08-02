# Handle alternatives from can-utils

inherit update-alternatives

ALTERNATIVE_PRIORITY = "100"
ALTERNATIVE_${PN} = "candump cansend"
ALTERNATIVE_LINK_NAME[candump] = "${bindir}/candump"
ALTERNATIVE_LINK_NAME[cansend] = "${bindir}/cansend"
