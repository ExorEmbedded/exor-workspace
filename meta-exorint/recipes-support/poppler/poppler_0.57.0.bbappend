# Enable support for qt4

PACKAGECONFIG ??= "jpeg openjpeg png tiff qt4"
PACKAGECONFIG[qt4] = "--enable-poppler-qt4 --with-moc-qt4=${STAGING_BINDIR_NATIVE}/moc4,--disable-poppler-qt4,qt4-x11-free"

RDEPENDS_libpoppler_remove = "poppler-data"
