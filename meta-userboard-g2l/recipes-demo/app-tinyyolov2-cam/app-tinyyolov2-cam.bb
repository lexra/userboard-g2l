APP_NAME = "app_tinyyolov2_cam"
MODEL = "tinyyolov2"
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
	install -d ${D}/home/root/${APP_NAME}/${MODEL}_${IMG_SRC}
	install ${WORKDIR}/exe/${MODEL}_${IMG_SRC}/* ${D}/home/root/${APP_NAME}/${MODEL}_${IMG_SRC} || true

	install -m 644 ${WORKDIR}/exe/*.txt ${D}/home/root/${APP_NAME} || true
	install -m 644 ${WORKDIR}/exe/*.bmp ${D}/home/root/${APP_NAME} || true
	install -m 755 ${S}/sample_${APP_NAME} ${D}/home/root/${APP_NAME}
}

do_compile_prepend() {
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S} clean
}

do_compile () {
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}
}

do_configure[noexec] = "1"
do_patch[noexec] = "1"

FILES_${PN} = " \
	/home/root/${APP_NAME} \
"

INSANE_SKIP_${PN} += " file-rdeps "
INSANE_SKIP_${PN}-dev += " file-rdeps "
