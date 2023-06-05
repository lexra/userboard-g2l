FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=8c0a1e9cae39a68671732f25792c6cde"

SRC_URI = " \
	git://github.com/D7EAD/liboai.git;protocol=https;branch=main \
	file://CMakeLists.patch \
	file://netimpl.patch \
"

SRCREV = "dda95109def12176bed30f443f904ab0356ce678"

DEPENDS += " nlohmann-json curl"

S = "${WORKDIR}/git/liboai"
B = "${WORKDIR}/build"

inherit cmake pkgconfig

ALLOW_EMPTY:${PN} = "1"
RDEPENDS:${PN}-dev = ""

BBCLASSEXTEND = "native nativesdk"

#OECMAKE_GENERATOR="Unix Makefiles"
#EXTRA_OECMAKE = " -DBUILD_SHARED_LIBS=ON "

do_install() {
	install -d ${D}${libdir}
	install -m 755 ${B}/liboai.so ${D}${libdir}
	install -d ${D}${includedir}/liboai
	cp -Rfv ${S}/include/components ${D}${includedir}/liboai
	cp -Rfv ${S}/include/core ${D}${includedir}/liboai
	cp -Rfv ${S}/include/liboai.h ${D}${includedir}/liboai
}

FILES_${PN}_append = " \
	${libdir} \
	${includedir}/liboai \
"

INSANE_SKIP_${PN} += " dev-elf "
INSANE_SKIP_${PN}-dev += " dev-elf "
