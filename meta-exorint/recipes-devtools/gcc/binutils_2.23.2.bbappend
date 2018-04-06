# Fix build with GCC 4.9.3
EXTRA_OEMAKE += ' CFLAGS="$CFLAGS -Wno-error=unused-value"'
