# Fix QA Issue: non debug package contains .debug directory
FILES_${PN}-engines = "${libdir}/engines-1.1/*.so"
FILES_${PN}-dbg += "${libdir}/engines-1.1/.debug/"
