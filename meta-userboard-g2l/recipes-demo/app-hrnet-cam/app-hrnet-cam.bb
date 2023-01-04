APP_NAME = "app_hrnet_cam"
MODEL = "hrnet"
IMG_SRC = "cam"

FILESEXTRAPATHS_prepend := "${THISDIR}/${APP_NAME}:"

LICENSE = "CLOSED"

inherit autotools pkgconfig

DEPENDS += " \
	drpai \
	opencv \
	wayland-protocols \
"

SRC_URI = " \
	file://etc \
	file://exe \
	file://src \
"

S = "${WORKDIR}/src"

do_install_class-target () {
	install -d ${D}/home/root/${APP_NAME}/exe/${MODEL}_${IMG_SRC}
	install ${WORKDIR}/exe/${MODEL}_${IMG_SRC}/* ${D}/home/root/${APP_NAME}/exe/${MODEL}_${IMG_SRC} || true

	install ${WORKDIR}/exe/sample_app* ${D}/home/root/${APP_NAME}/exe || true
	install ${WORKDIR}/exe/*.txt ${D}/home/root/${APP_NAME}/exe || true
	install ${WORKDIR}/exe/*.bmp ${D}/home/root/${APP_NAME}/exe || true

	install -d ${D}/home/root/${APP_NAME}/etc
	install ${WORKDIR}/etc/*.yaml ${D}/home/root/${APP_NAME}/etc || true
	install ${S}/sample_app_${MODEL}_${IMG_SRC} ${D}/home/root/${APP_NAME}/exe
}

do_compile_prepend() {
	SDKTARGETSYSROOT=${STAGING_DIR_TARGET} oe_runmake -C ${S} clean
}

do_compile () {
	SDKTARGETSYSROOT=${STAGING_DIR_TARGET} oe_runmake -C ${S}
}

do_configure[noexec] = "1"
do_patch[noexec] = "1"

FILES_${PN} = " \
	/home/root/${APP_NAME} \
"

INSANE_SKIP_${PN} += " file-rdeps "
INSANE_SKIP_${PN}-dev += " file-rdeps "
