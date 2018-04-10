#@TYPE: Machine

require conf/machine/include/tune-cortexa8.inc
require exor.inc

# Make sure hard fp is enabled (-mfloat-abi=hard GCC option)
DEFAULTTUNE = "cortexa8hf-neon"

SERIAL_DEV = "ttyO"

SERIAL_CONSOLE = "115200 ${SERIAL_DEV}0"

MACHINEOVERRIDES =. "usom01:"
