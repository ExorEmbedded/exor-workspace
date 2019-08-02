#@TYPE: Machine

require exor.inc
require conf/machine/include/tune-cortexa7.inc

# Make sure hard fp is enabled (-mfloat-abi=hard GCC option)
DEFAULTTUNE = "cortexa7hf-neon"

SERIAL_DEV = "ttymxc"

SERIAL_CONSOLE = "115200 ${SERIAL_DEV}0"

MACHINEOVERRIDES =. "nsom01:"
