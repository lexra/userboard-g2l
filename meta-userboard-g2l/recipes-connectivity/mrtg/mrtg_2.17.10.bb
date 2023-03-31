FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

require mrtg.inc

LIC_FILES_CHKSUM = "file://COPYING;md5=18810669f13b87348459e611d31ab760"
LICENSE = "GPL"

SRC_URI_append = " \
        file://configure.patch \
	file://cfgmaker \
	file://indexmaker \
	file://mrtg \
"
SRC_URI[mrtg-2.17.10.md5sum] = "ab1c14acc9af4221f459707339f361b3"
SRC_URI[mrtg-2.17.10.sha256sum] = "c7f11cb5e217a500d87ee3b5d26c58a8652edbc0d3291688bb792b010fae43ac"

S = "${WORKDIR}/${PN}-${PV}"
B = "${WORKDIR}/${PN}-${PV}"

inherit pkgconfig

do_configure_prepend () {
        export long_long_format_specifier="%lld"
        rm -rfv ./configure
}

do_configure () {
        autoconf
        ./configure --host=aarch64-poky-linux --prefix=/usr --libdir=${libdir}/perl5/5.30.1
}

do_compile () {
        oe_runmake
}

do_install_class-target () {
	install -d ${D}${bindir}
	install -d ${D}${libdir}/perl5/5.30.1
	install -d ${D}${datadir}/mrtg2/icons

	install -m 755 ${S}/bin/rateup ${D}${bindir}
	install -m 755 ${WORKDIR}/cfgmaker ${D}${bindir}
	install -m 755 ${WORKDIR}/indexmaker ${D}${bindir}
	install -m 755 ${WORKDIR}/mrtg ${D}${bindir}
	install -m 755 ${S}/bin/mrtg-traffic-sum ${D}${bindir}

	cp -Rfv ${S}/lib/mrtg2 ${D}${libdir}/perl5/5.30.1
	cp -Rfv ${S}/images/* ${D}${datadir}/mrtg2/icons
}

FILES_${PN} += " \
        ${libdir} \
        ${bindir} \
        ${datadir} \
"

INSANE_SKIP_${PN} += " file-rdeps "
INSANE_SKIP_${PN}-dev += " file-rdeps "
