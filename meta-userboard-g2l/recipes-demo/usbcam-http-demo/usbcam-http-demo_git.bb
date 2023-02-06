FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=e3da7ab23b52a5de7ef39aea4addc59f"
LICENSE = "MIT"

SRCREV = "ceacb18ba51d7e818b462f7eb23516132b8f00b8"
SRC_URI = " \
	git://github.com/renesas-rz/rzv2l_smarc_sample_code.git;protocol=https;branch=main \
	file://coco-labels-2014_2017.txt \
	file://synset_words_imagenet.txt \
"

inherit cmake pkgconfig

DEPENDS += " \
        drpai \
        opencv \
        wayland-protocols \
"

S = "${WORKDIR}/git/usbcam_http_drp-ai/src"
B = "${WORKDIR}/build"

do_install_class-target () {
	install -d ${D}/home/root/${PN}/etc/hrnet_cam
	install -d ${D}/home/root/${PN}/etc/resnet50_cam
	install -d ${D}/home/root/${PN}/etc/tinyyolov2_cam
	install -d ${D}/home/root/${PN}/etc/yolov3_cam
	install ${S}/../etc/hrnet_cam/*.yaml ${D}/home/root/${PN}/etc/hrnet_cam
	install ${S}/../etc/resnet50_cam/*.yaml ${D}/home/root/${PN}/etc/resnet50_cam
	install ${S}/../etc/tinyyolov2_cam/*.yaml ${D}/home/root/${PN}/etc/tinyyolov2_cam
	install ${S}/../etc/yolov3_cam/*.yaml ${D}/home/root/${PN}/etc/yolov3_cam

	install -d ${D}/home/root/${PN}/exe/hrnet_cam
	install -d ${D}/home/root/${PN}/exe/resnet50_cam
	install -d ${D}/home/root/${PN}/exe/tinyyolov2_cam
	install -d ${D}/home/root/${PN}/exe/yolov3_cam

	install -d ${D}/home/root/${PN}/css
	install -d ${D}/home/root/${PN}/js
	install -d ${D}/home/root/${PN}/libs

	install ${B}/sample_app_usbcam_http ${D}/home/root/${PN}/exe
	install ${WORKDIR}/coco-labels-2014_2017.txt ${D}/home/root/${PN}/exe
	install ${WORKDIR}/synset_words_imagenet.txt ${D}/home/root/${PN}/exe

	install ${S}/../etc/Websocket_Client/index.html ${D}/home/root/${PN}
	install ${S}/../etc/Websocket_Client/css/websocket_demo.css ${D}/home/root/${PN}/css
	install ${S}/../etc/Websocket_Client/js/websocket_demo.js ${D}/home/root/${PN}/css
	install ${S}/../etc/Websocket_Client/libs/bootstrap.min.css ${D}/home/root/${PN}/libs
	install ${S}/../etc/Websocket_Client/libs/bootstrap.min.js ${D}/home/root/${PN}/libs
	install ${S}/../etc/Websocket_Client/libs/moment.min.js ${D}/home/root/${PN}/libs
}

FILES_${PN} = " \
        /home/root/${PN} \
"

INSANE_SKIP_${PN} += " installed-vs-shipped "
INSANE_SKIP_${PN}-dev += " installed-vs-shipped "
