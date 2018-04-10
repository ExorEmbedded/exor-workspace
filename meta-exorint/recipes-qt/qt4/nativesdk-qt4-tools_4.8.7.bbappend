# Disable .pch files generati which may cause build issues
EXTRA_OECONF += " -no-pch"

TOBUILD = "\
  src/tools/bootstrap \
  src/tools/moc \
  src/corelib \
  src/sql \
  src/xml \
  src/dbus \
  src/network \
  src/gui \
  src/qt3support \
  src/tools/uic \
  src/tools/rcc \
  src/tools/uic3 \
  tools/linguist/lrelease \
  tools/linguist/lupdate \
  tools/qdbus \
"
do_install() {
    install -d ${D}${bindir}
    install -d ${D}${libdir}

    install -m 0755 bin/qmake2 ${D}${bindir}/qmake2
    for i in moc uic uic3 rcc lrelease lupdate qdbuscpp2xml qdbusxml2cpp; do
        install -m 0755 bin/${i} ${D}${bindir}/${i}4
    done

    for i in  libQt3Support.so.4 libQtCore.so.4 libQtDBus.so.4 libQtGui.so.4 libQtNetwork.so.4 libQtSql.so.4 libQtXml.so.4; do
        install -m 0766 lib/${i} ${D}${libdir}/${i}
    done

    (cd ${D}${bindir}; \
    ln -s qmake2 qmake; \
    for i in moc uic uic3 rcc lrelease lupdate qdbuscpp2xml qdbusxml2cpp; do \
        ln -s ${i}4 ${i}; \
    done)

    install -d ${D}${sysconfdir}
    cat >${D}${sysconfdir}/qt.conf <<EOF
[Paths]
Prefix = ${prefix}
EOF
}
