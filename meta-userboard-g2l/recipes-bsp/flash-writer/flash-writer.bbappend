FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://qspiFlash-writer-helper \
	file://rzv2l_cm33_rpmsg_demo*.bin \
"
SRC_URI_append_smarc-rzg2l = " file://makefile "
SRC_URI_append_smarc-rzg2lc = " file://makefile "
SRC_URI_append_smarc-rzv2l = " file://makefile "
SRC_URI_append_smarc-rzv2ul = " file://makefile "
SRC_URI_append_rzv2l-dev = " file://makefile "

do_compile () {
	#cp -fv ${WORKDIR}/makefile ${S} || true

	if [ "${MACHINE}" == "gnk-rzg2l" ]; then
		BOARD="GNK_RZG2L";
		PMIC_BOARD="GNK_RZG2L";
	fi
	if [ "${MACHINE}" == "gnk-rzv2l" ]; then
		BOARD="GNK_RZV2L";
		PMIC_BOARD="GNK_RZV2L";
	fi
	if [ "${MACHINE}" == "smarc-rzg2l" ]; then
		BOARD="RZG2L_SMARC";
		PMIC_BOARD="RZG2L_SMARC_PMIC";
	fi
	if [ "${MACHINE}" == "smarc-rzg2lc" ]; then
		BOARD="RZG2LC_SMARC";
	fi
	if [ "${MACHINE}" == "smarc-rzg2ul" ]; then
		BOARD="RZG2UL_SMARC";
	fi
	if [ "${MACHINE}" == "smarc-rzv2l" ]; then
		BOARD="RZV2L_SMARC";
		PMIC_BOARD="RZV2L_SMARC_PMIC";
	fi
	if [ "${MACHINE}" == "rzv2l-dev" ]; then
		BOARD="RZV2L_15MMSQ_DEV";
	fi

	cd ${S}
	oe_runmake BOARD=${BOARD} clean
	oe_runmake BOARD=${BOARD}
	if [ "${PMIC_SUPPORT}" == "1" ]; then
		oe_runmake OUTPUT_DIR=${PMIC_BUILD_DIR} clean;
		oe_runmake BOARD=${PMIC_BOARD} OUTPUT_DIR=${PMIC_BUILD_DIR};
	fi
}

do_deploy_append () {
	install -d ${DEPLOYDIR}
	install -m 755 ${WORKDIR}/rzv2l_cm33_rpmsg_demo*.bin ${DEPLOYDIR}
	install -m 755 ${WORKDIR}/qspiFlash-writer-helper ${DEPLOYDIR}
}
