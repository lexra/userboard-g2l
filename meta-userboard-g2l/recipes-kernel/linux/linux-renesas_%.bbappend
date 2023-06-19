FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
	file://nfsd.cfg \
"

#	file://0101-clock_frequency_16000000.patch

SRC_URI_append_gnk-rzv2l = " \
	file://0999-gnk_v2l-modify-drp_reserved.patch \
"

COMPATIBLE_MACHINE_rzg2l = "(smarc-rzg2l|gnk-rzg2l)"
COMPATIBLE_MACHINE_rzv2l = "(smarc-rzv2l|rzv2l-dev|gnk-rzv2l)"

EXTRA_OEMAKE_append = " V=1"
