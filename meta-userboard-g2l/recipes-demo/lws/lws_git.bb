FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=f3443d5f6deaa2b91fc0510ef4768b5e"
LICENSE = "MIT"

SRCREV = "6e7af4a16d8878fbfadf01cb98d7edf3ecc8a29d"
SRC_URI = " \
	git://github.com/renesas-rz/rzfive_smarc_sample_code.git;protocol=https;branch=main \
	file://lws.service \
	file://lws.sh \
"

DEPENDS = " \
        jansson \
        libwebsockets \
"

inherit cmake systemd pkgconfig

#SYSTEMD_SERVICE_${PN} = "lws.service"
SYSTEMD_PACKAGES = "${PN}"
SYSTEMD_AUTO_ENABLE = "disable"

S = "${WORKDIR}/git/demo_env/apps/sources"
B = "${WORKDIR}/build"

do_install_class-target () {
	install -d ${D}/home/root/lws/apps
	install -d ${D}/home/root/lws/css
	install -d ${D}/home/root/lws/img
	install -d ${D}/home/root/lws/js
	install -d ${D}/home/root/lws/libs
	install -m 755 ${B}/lws-minimal-ws-server-threads ${D}/home/root/lws/apps

	install ${S}/../../libs/bootstrap.min.css ${D}/home/root/lws/libs
	install ${S}/../../libs/bootstrap.min.js ${D}/home/root/lws/libs
	install ${S}/../../libs/Chart.min.js ${D}/home/root/lws/libs
	install ${S}/../../libs/jquery-3.4.1.min.js ${D}/home/root/lws/libs
	install ${S}/../../libs/moment.min.js ${D}/home/root/lws/libs

	install ${S}/../../css/websocket_demo.css ${D}/home/root/lws/css
	install ${S}/../../js/websocket_demo.js ${D}/home/root/lws/js

	install ${S}/../../img/icon_hum.png ${D}/home/root/lws/img
	install ${S}/../../img/icon_illumi.png ${D}/home/root/lws/img
	install ${S}/../../img/icon_led-off.png ${D}/home/root/lws/img
	install ${S}/../../img/icon_led-on.png ${D}/home/root/lws/img
	install ${S}/../../img/icon_temp.png ${D}/home/root/lws/img
	install ${S}/../../img/settings_close.png ${D}/home/root/lws/img
	install ${S}/../../img/settings_open.png ${D}/home/root/lws/img

	install ${S}/../../index.html ${D}/home/root/lws

	install -m 755 ${WORKDIR}/lws.sh ${D}/home/root/lws/apps
	install -d ${D}${system_unitdir}
	install ${WORKDIR}/lws.service ${D}${system_unitdir}
}

FILES_${PN} = " \
        /home/root/lws \
	${system_unitdir} \
"

INSANE_SKIP_${PN} += " installed-vs-shipped "
INSANE_SKIP_${PN}-dev += " installed-vs-shipped "
