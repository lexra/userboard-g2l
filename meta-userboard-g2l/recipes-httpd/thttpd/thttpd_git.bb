FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LICENSE = "FreeBSD"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/README;md5=36371044a9cdfeca561b979be04e88ed"

SRCREV = "0066035fc65d190186486a478c61f0b592e7224c"
SRC_URI = " \
	git://github.com/jpouellet/thttpd.git;protocol=https;branch=master \
	file://init \
"

SRC_URI_append = " \
	${@'' if (d.getVar("CIP_MODE") == 'Buster' or d.getVar("CIP_MODE") == 'Bullseye') else 'file://poll.patch' } \
"

S = "${WORKDIR}/git"

DEPENDS += " \
	libnsl2 \
	libpcap \
	libpthread-stubs \
"

PARALLEL_MAKE = ""

INITSCRIPT_NAME = "thttpd"
INITSCRIPT_PARAMS = "start 8 5 2 . stop 21 0 1 6 ."

#inherit pkgconfig update-rc.d
inherit pkgconfig

WEBDIR_DEMO = "${localstatedir}/demo"
WEBDIR_TVM = "${localstatedir}/tvm"

EXTRA_OEMAKE += " \
	WEBDIR=${WEBDIR_DEMO} \
"

do_configure () {
	./configure --prefix=${prefix}
}

do_install_class-target () {
	install -d ${D}${sbindir}
	install -d ${D}${WEBDIR_DEMO}/cgi-bin
	install -d ${D}${WEBDIR_TVM}/cgi-bin
	install -d ${D}${sysconfdir}/init.d

	install -m 755 ${S}/thttpd ${D}${sbindir}
	install -m 755 ${S}/extras/makeweb ${D}${sbindir}
	install -m 755 ${S}/extras/htpasswd ${D}${sbindir}
	install -m 755 ${S}/extras/syslogtocern ${D}${sbindir}

	install -m 755 ${S}/cgi-src/phf ${D}${WEBDIR_DEMO}/cgi-bin
	install -m 755 ${S}/cgi-src/redirect ${D}${WEBDIR_DEMO}/cgi-bin
	install -m 755 ${S}/cgi-src/ssi ${D}${WEBDIR_DEMO}/cgi-bin

	install -m 755 ${S}/cgi-src/phf ${D}${WEBDIR_TVM}/cgi-bin
	install -m 755 ${S}/cgi-src/redirect ${D}${WEBDIR_TVM}/cgi-bin
	install -m 755 ${S}/cgi-src/ssi ${D}${WEBDIR_TVM}/cgi-bin

	cat ${WORKDIR}/init | sed -e 's,@@SRVDIR,${WEBDIR_DEMO},g' > ${WORKDIR}/thttpd
	install -c -m 755 ${WORKDIR}/thttpd ${D}${sysconfdir}/init.d/thttpd
}

FILES_${PN}_append = " \
	${sbindir} \
	${WEBDIR_DEMO} \
	${WEBDIR_TVM} \
	${sysconfdir} \
"
