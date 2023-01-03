APP_NAME = "app_hrnet_pre-tinyyolov2_cam"
MODEL = "hrnet"
IMG_SRC = "cam"

FILESEXTRAPATHS_prepend := "${THISDIR}/${APP_NAME}:"

LICENSE = "CLOSED"

SRC_URI = " \
	file://etc \
	file://exe \
"

S = "${WORKDIR}"

do_install_class-target () {
	MODEL=hrnet
	install -d ${D}/home/root/${APP_NAME}/exe/${MODEL}_${IMG_SRC}
	install ${WORKDIR}/exe/${MODEL}_${IMG_SRC}/* ${D}/home/root/${APP_NAME}/exe/${MODEL}_${IMG_SRC} || true

	MODEL=tinyyolov2
	install -d ${D}/home/root/${APP_NAME}/exe/${MODEL}_${IMG_SRC}
	install ${WORKDIR}/exe/${MODEL}_${IMG_SRC}/* ${D}/home/root/${APP_NAME}/exe/${MODEL}_${IMG_SRC} || true

	install ${WORKDIR}/exe/sample_app* ${D}/home/root/${APP_NAME}/exe || true
	install ${WORKDIR}/exe/*.txt ${D}/home/root/${APP_NAME}/exe || true
	install ${WORKDIR}/exe/*.bmp ${D}/home/root/${APP_NAME}/exe || true

	install -d ${D}/home/root/${APP_NAME}/etc
	install ${WORKDIR}/etc/*.yaml ${D}/home/root/${APP_NAME}/etc || true
}

do_configure[noexec] = "1"
do_patch[noexec] = "1"
do_compile[noexec] = "1"

FILES_${PN} = " \
	/home/root/${APP_NAME} \
"

INSANE_SKIP_${PN} += " file-rdeps "
INSANE_SKIP_${PN}-dev += " file-rdeps "
