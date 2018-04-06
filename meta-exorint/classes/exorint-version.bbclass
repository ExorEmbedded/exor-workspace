# Exorint version file parsing

def componentToHuman (component):
    if component == "M":
        return "mainos"
    elif component == "C":
        return "configos"
    elif component == "X":
        return "xloader"
    elif component == "B":
        return "bootloader"
    elif component == "K":
        return "kernel"
    elif component == "S":
        return "sdk"
    else:
        return None

python () {

    import re

    version = d.getVar('VERSION', True)
    if version is None:
        bb.fatal("VERSION undefined!")

    bb.note("Checking version: %s" % version)

    m = re.match(r"^(\w{4})(\w{4})(\w{1})(\d{2})(\d{3})(\d{3})(\w{2})?$", version)
    if m is None:
        bb.fatal("Bad version: '%s'. Please check format!" % version)

    cpu = m.group(1)
    carrier = m.group(2)
    component = m.group(3)
    major = int(m.group(4))
    minor = int(m.group(5))
    build = int(m.group(6))
    customer = m.group(7)

    if customer is None:
        customer = ""

    bb.note("Version check OK! cpu: %s, carrier: %s, component: %s, major: %d, minor: %d, build: %d, customer: %s" %
            (cpu, carrier, component, major, minor, build, customer))

    pr = "r%s%d.%d.%d" % (component, major, minor, build)

    bb.note("Setting PR: " + pr)
    d.setVar("PR", pr)

    compstr = componentToHuman(component)
    if compstr is None:
        bb.fatal("Bad component: %s!" % component)

    vhuman_nover = "%s-%s-%s" % (cpu.lower(), carrier.lower(), compstr)
    d.setVar("VERSION_HUMAN_NOVER", vhuman_nover)

    vhuman_ver = "%d.%d.%d" % (major, minor, build)
    d.setVar("VERSION_HUMAN_VER", vhuman_ver)

    vhuman = vhuman_nover + "-" + vhuman_ver
    if customer != "":
        vhuman += "-" + customer

    vtag = d.getVar('EXOS_VERSION_TAG', True)
    if vtag and vtag != "":
        vhuman += "-" + vtag;

    d.setVar("VERSION_HUMAN", vhuman)
}
