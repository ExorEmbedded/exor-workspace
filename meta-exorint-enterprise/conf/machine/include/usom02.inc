#@TYPE: Machine

require exor.inc
require conf/machine/include/tune-cortexa8.inc

# Make sure hard fp is enabled (-mfloat-abi=hard GCC option)
# Note that the machine has a cortex-A9 processor. However optimizations for a9 should't have a big impact,
# to avoid having different binaries between uSOM01 and uSOM02 we are compiling for a8 for now.
DEFAULTTUNE = "cortexa8hf-neon"

SERIAL_DEV = "ttyS"

SERIAL_CONSOLE = "115200 ${SERIAL_DEV}0"

MACHINEOVERRIDES =. "usom02:"
