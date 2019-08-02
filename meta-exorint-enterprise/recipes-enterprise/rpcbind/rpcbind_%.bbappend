PR := "${PR}.x0"

#INITSCRIPT_PARAMS_wu16 = "start 12 5 . start 32 0 6 . stop 81 1 ."

# Temporarily disabled to avoid RPC vulnerabilities [#1508]
INITSCRIPT_PARAMS = "start 10 . stop 10 ."
