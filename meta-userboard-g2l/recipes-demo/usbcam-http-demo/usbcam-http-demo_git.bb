FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=e3da7ab23b52a5de7ef39aea4addc59f"
LICENSE = "MIT"

SRCREV = "ceacb18ba51d7e818b462f7eb23516132b8f00b8"
SRC_URI = " \
	git://github.com/renesas-rz/rzv2l_smarc_sample_code.git;protocol=https;branch=main \
	file://coco-labels-2014_2017.txt \
	file://synset_words_imagenet.txt \
	file://hrnet_cam \
	file://resnet50_cam \
	file://tinyyolov2_cam \
	file://yolov3_cam \
"

inherit cmake pkgconfig

DEPENDS += " \
	drpai \
	opencv \
	wayland-protocols \
"

S = "${WORKDIR}/git/usbcam_http_drp-ai/src"
B = "${WORKDIR}/build"
WEBDIR = "${localstatedir}/demo"

do_install_class-target () {
	install -d ${D}/home/root/${PN}/hrnet_cam
	install -d ${D}/home/root/${PN}/resnet50_cam
	install -d ${D}/home/root/${PN}/tinyyolov2_cam
	install -d ${D}/home/root/${PN}/yolov3_cam
	install -d ${D}${WEBDIR}/css
	install -d ${D}${WEBDIR}/js
	install -d ${D}${WEBDIR}/libs

	install ${B}/sample_app_usbcam_http ${D}/home/root/${PN}
	install ${WORKDIR}/coco-labels-2014_2017.txt ${D}/home/root/${PN}
	install ${WORKDIR}/synset_words_imagenet.txt ${D}/home/root/${PN}

	install ${WORKDIR}/hrnet_cam/* ${D}/home/root/${PN}/hrnet_cam
	install ${WORKDIR}/resnet50_cam/* ${D}/home/root/${PN}/resnet50_cam
	install ${WORKDIR}/tinyyolov2_cam/* ${D}/home/root/${PN}/tinyyolov2_cam
	install ${WORKDIR}/yolov3_cam/* ${D}/home/root/${PN}/yolov3_cam

	install -m 644 ${S}/../etc/Websocket_Client/index.html ${D}${WEBDIR}
	install -m 644 ${S}/../etc/Websocket_Client/css/*.css ${D}${WEBDIR}/css
	install -m 644 ${S}/../etc/Websocket_Client/js/*.js ${D}${WEBDIR}/js
	install -m 644 ${S}/../etc/Websocket_Client/libs/*.css ${D}${WEBDIR}/libs
	install -m 644 ${S}/../etc/Websocket_Client/libs/*.js ${D}${WEBDIR}/libs
}

FILES_${PN} = " \
	/home/root/${PN} \
	${WEBDIR} \
"

INSANE_SKIP_${PN} += " installed-vs-shipped "
INSANE_SKIP_${PN}-dev += " installed-vs-shipped "
