FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PR := "${PR}.x0"

# Use sysvinit pidof
base_bindir_progs_remove = "pidof"
