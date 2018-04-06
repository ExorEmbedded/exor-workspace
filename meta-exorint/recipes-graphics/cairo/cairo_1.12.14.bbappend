# Disable LTO optimization. Fixes build with gcc 4.9

CFLAGS += " -fno-lto"
