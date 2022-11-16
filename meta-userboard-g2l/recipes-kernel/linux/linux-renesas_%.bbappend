FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
	${@oe.utils.conditional('MACHINE', 'gnk-rzg2l', 'file://panel.cfg', '', d)} \
	${@oe.utils.conditional('MACHINE', 'gnk-rzv2l', 'file://panel.cfg', '', d)} \
	file://nfsd.cfg \
"

COMPATIBLE_MACHINE_rzg2l = "(smarc-rzg2l|smarc-rzg2lc|smarc-rzg2ul|smarc-rzv2l|rzv2l-dev|gnk-rzg2l|gnk-rzv2l)"

EXTRA_OEMAKE_append = " V=1"
