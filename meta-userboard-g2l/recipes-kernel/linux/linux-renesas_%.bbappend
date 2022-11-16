FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
	${@oe.utils.conditional('MACHINE', 'gnk-rzg2l', 'file://panel.cfg', '', d)} \
	${@oe.utils.conditional('MACHINE', 'gnk-rzv2l', 'file://panel.cfg', '', d)} \
	file://nfsd.cfg \
"

COMPATIBLE_MACHINE_rzg2l = "(smarc-rzg2l|gnk-rzg2l)"
COMPATIBLE_MACHINE_rzv2l = "(smarc-rzv2l|rzv2l-dev|gnk-rzv2l)"

EXTRA_OEMAKE_append = " V=1"
