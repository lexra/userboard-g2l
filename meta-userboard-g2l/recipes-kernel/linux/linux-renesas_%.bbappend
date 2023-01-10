FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
	file://nfsd.cfg \
"
#SRC_URI_append_gnk-rzg2l = " file://panel.cfg "
#SRC_URI_append_gnk-rzv2l = " file://panel.cfg "

COMPATIBLE_MACHINE_rzg2l = "(smarc-rzg2l|gnk-rzg2l)"
COMPATIBLE_MACHINE_rzv2l = "(smarc-rzv2l|rzv2l-dev|gnk-rzv2l)"

EXTRA_OEMAKE_append = " V=1"
