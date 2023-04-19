FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=7c0d7ef03a7eb04ce795b0f60e68e7e1"

DEPENDS += " \
	glib-2.0 \
	libdrm \
	libpng \
	libsdl2 \
	wayland wayland-protocols \
	virtual/libgles2 \
"

SRC_URI_append = " \
        file://Makefile \
        file://drm2png.c \
        file://fbgrab.c \
        file://i2c_read_data.c \
        file://ntpc.c \
        file://hello_triangle.cpp \
        file://gles_linux.c \
        file://init_window.c \
        file://init_window.h \
        file://log.h \
	file://COPYING \
"

#TARGET_CC_ARCH += "${LDFLAGS}"
#LD[unexport] = "1"

inherit pkgconfig

S = "${WORKDIR}"

FILES_${PN} += " \
	${bindir}/drm2png \
	${bindir}/fbgrab \
	${bindir}/i2c_read_data \
	${bindir}/ntpc \
	/home/root/sdl-tests \
"
FILES_${PN}-dev = ""

do_compile () {
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}
}

do_install_class-target () {
	install -d ${D}${bindir}
	install ${S}/drm2png ${D}${bindir}
	install ${S}/fbgrab ${D}${bindir}
	install ${S}/i2c_read_data ${D}${bindir}
	install ${S}/ntpc ${D}${bindir}

	install -d ${D}/home/root/sdl-tests
	install ${S}/hello_triangle ${D}/home/root/sdl-tests
	install ${S}/gles_linux ${D}/home/root/sdl-tests
	install ${S}/init_window ${D}/home/root/sdl-tests
}

do_configure[noexec] = "1"
