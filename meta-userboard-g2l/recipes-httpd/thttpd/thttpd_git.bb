FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LICENSE = "FreeBSD"
LIC_FILES_CHKSUM = "file://${WORKDIR}/git/README;md5=36371044a9cdfeca561b979be04e88ed"

SRCREV = "0066035fc65d190186486a478c61f0b592e7224c"
SRC_URI = " \
	git://github.com/jpouellet/thttpd.git;protocol=https;branch=master \
	file://init \
"

S = "${WORKDIR}/git"

DEPENDS += " \
	libnsl2 \
	libpcap \
	libpthread-stubs \
"

PARALLEL_MAKE = ""

INITSCRIPT_NAME = "thttpd"
INITSCRIPT_PARAMS = "defaults"
#INITSCRIPT_PARAMS = "start 8 5 2 . stop 21 0 1 6 ."

inherit pkgconfig update-rc.d

WEBDIR = "${localstatedir}/thttpd"

EXTRA_OEMAKE += " \
	WEBDIR=${WEBDIR} \
"

do_configure () {
	./configure --prefix=${prefix}
}

do_install_class-target () {
	install -d ${D}${sbindir}
	install -d ${D}${WEBDIR}/cgi-bin
	install -d ${D}${sysconfdir}/init.d

	install -m 755 ${S}/thttpd ${D}${sbindir}
	install -m 755 ${S}/extras/makeweb ${D}${sbindir}
	install -m 755 ${S}/extras/htpasswd ${D}${sbindir}
	install -m 755 ${S}/extras/syslogtocern ${D}${sbindir}

	install -m 755 ${S}/cgi-src/phf ${D}${WEBDIR}/cgi-bin
	install -m 755 ${S}/cgi-src/redirect ${D}${WEBDIR}/cgi-bin
	install -m 755 ${S}/cgi-src/ssi ${D}${WEBDIR}/cgi-bin

	cat ${WORKDIR}/init | sed -e 's,@@SRVDIR,${WEBDIR},g' > ${WORKDIR}/thttpd
	install -c -m 755 ${WORKDIR}/thttpd ${D}${sysconfdir}/init.d/thttpd
}

FILES_${PN}_append = " \
	${sbindir} \
	${WEBDIR} \
	${sysconfdir} \
"
