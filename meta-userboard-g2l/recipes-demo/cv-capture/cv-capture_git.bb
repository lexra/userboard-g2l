LIC_FILES_CHKSUM = "file://${WORKDIR}/git/Disclaimer.txt;md5=d41d8cd98f00b204e9800998ecf8427e"
LICENSE = "CLOSED"

SRCREV = "f91a11a647cd2e04614cead2e18e6ad94f18d72c"
SRC_URI = " \
        git://github.com/renesas-rz/rzg2l_smarc_sample_code.git;protocol=https;branch=master \
"

inherit cmake pkgconfig

DEPENDS += " \
	opencv \
	v4l-utils \
	libgpiod \
"

EXTRA_OECMAKE = " \
	-DCMAKE_SYSROOT=${WORKDIR}/recipe-sysroot \
"

S = "${WORKDIR}/git/camera-examples/openCV-examples/openCV-captureImage"
B = "${WORKDIR}/build"

do_compile_append () {
	oe_runmake -C ${S}/../../camera-latency
	oe_runmake -C ${S}/../../../gpio-examples/libgpiod-examples/libgpiod-event
	oe_runmake -C ${S}/../../../gpio-examples/libgpiod-examples/libgpiod-input
	oe_runmake -C ${S}/../../../gpio-examples/libgpiod-examples/libgpiod-led
}

do_install_class-target () {
	install -d ${D}${bindir}
	install ${B}/openCV-captureImage ${D}${bindir}
	install ${S}/../../camera-latency/camera-latency ${D}${bindir}
	install ${S}/../../../gpio-examples/libgpiod-examples/libgpiod-event/libgpiod-event-button ${D}${bindir}
	install ${S}/../../../gpio-examples/libgpiod-examples/libgpiod-input/libgpiod-input ${D}${bindir}
	install ${S}/../../../gpio-examples/libgpiod-examples/libgpiod-led/libgpiod-led ${D}${bindir}
}

FILES_${PN} += " \
	${bindir}/openCV-captureImage \
	${bindir}/camera-latency \
	${bindir}/libgpiod-event-button \
	${bindir}/libgpiod-input \
	${bindir}/libgpiod-led \
"

INSANE_SKIP_${PN} += " ldflags "
INSANE_SKIP_${PN}-dev += " ldflags "
