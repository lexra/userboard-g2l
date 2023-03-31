SECTION = "net"

DEPENDS = "gd perl-native"

RDEPENDS_${PN} = " \
	 gd \
	 net-snmp-server \
	 perl \
	 perl-module-carp-heavy \
	 perl-module-findbin \
	 perl-module-getopt-long \
	 perl-module-io \
	 perl-module-io-socket \
	 perl-module-locale \
	 perl-module-math-bigfloat \
	 perl-module-math-bigint \
	 perl-module-overload \
	 perl-module-pod-text \
	 perl-module-universal \
"

PR = "r1"

SRC_URI = "http://oss.oetiker.ch/mrtg/pub/mrtg-${PV}.tar.gz;name=mrtg-${PV}"

