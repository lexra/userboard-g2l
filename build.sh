#!/bin/bash -e

##########################################################
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
IP_ADDR=$(ip address | grep 192.168 | head -1 | awk '{print $2}' | awk -F '/' '{print $1}')

HMI=qt
CORE_IMAGE=core-image-${HMI}
SOC_FAMILY=r9a07g044l
SOC_FAMILY_PLUS=${SOC_FAMILY}2
SCRIP_DIR=$(pwd)

BOARD_LIST=("smarc-rzg2l" "smarc-rzv2l" "rzv2l-dev" "gnk-rzg2l" "gnk-rzv2l")
TARGET_BOARD=$1
BUILD_DIR=build_${TARGET_BOARD}
[ "${TARGET_BOARD}" == "smarc-rzv2l" ] && SOC_FAMILY=r9a07g054l
[ "${TARGET_BOARD}" == "rzv2l-dev" ] && SOC_FAMILY=r9a07g054l
[ "${TARGET_BOARD}" == "gnk-rzv2l" ] && SOC_FAMILY=r9a07g054l

##########################################################
function Usage () {
        echo "Usage: $0 \${TARGET_BOARD_NAME}"
        echo "BOARD_NAME list: "
        for i in ${BOARD_LIST[@]}; do echo "  - $i"; done
        exit 0
}
if ! `IFS=$'\n'; echo "${BOARD_LIST[*]}" | grep -qx "${TARGET_BOARD}"`; then
        Usage
fi

##########################################################
function print_boot_example() {
	echo ""
	echo ">> FOR QSPI FLASH BOOT"
	echo -e "${YELLOW} => setenv bootmmc 'setenv bootargs rw rootwait earlycon root=/dev/mmcblk0p2 video=HDMI-A1:1280x720@60; fatload mmc 0:1 0x48080000 Image; fatload mmc 0:1 0x48000000 ${SOC_FAMILY_PLUS}-${TARGET_BOARD}.dtb; booti 0x48080000 - 0x48000000' ${NC}"
	echo -e "${YELLOW} => run bootmmc ${NC}"
	echo ""
	echo ">> FOR SD BOOT"
	echo -e "${YELLOW} => setenv bootsd 'setenv bootargs rw rootwait earlycon root=/dev/mmcblk1p2 video=HDMI-A1:1280x720@60; fatload mmc 1:1 0x48080000 Image; fatload mmc 1:1 0x48000000 ${SOC_FAMILY_PLUS}-${TARGET_BOARD}.dtb; booti 0x48080000 - 0x48000000' ${NC}"
	echo -e "${YELLOW} => run bootsd ${NC}"
	echo ""
	echo ">> FOR USB BOOT"
	echo -e "${YELLOW} => setenv bootusb 'setenv bootargs rw rootwait earlycon root=/dev/sda2 video=HDMI-A1:1280x720@60; usb reset; fatload usb 0:1 0x48080000 Image; fatload usb 0:1 0x48000000 ${SOC_FAMILY_PLUS}-${TARGET_BOARD}.dtb; booti 0x48080000 - 0x48000000' ${NC}"
	echo -e "${YELLOW} => run bootusb ${NC}"
	echo ""
	echo ">> FOR NFS BOOT"
	echo -e "${YELLOW} => setenv ethaddr 2E:09:0A:00:BE:11 ${NC}"
	echo -e "${YELLOW} => setenv ipaddr $(echo ${IP_ADDR} | grep 192.168 | head -1 | awk -F '.' '{print $1 "." $2 "." $3}').133; setenv serverip ${IP_ADDR}; setenv NFSROOT \${serverip}:$(pwd)/rootfs ${NC}"
	echo -e "${YELLOW} => setenv bootnfs 'nfs 0x48080000 \${NFSROOT}/boot/Image; nfs 0x48000000 \${NFSROOT}/boot/${SOC_FAMILY_PLUS}-${TARGET_BOARD}.dtb; setenv bootargs rw rootwait earlycon root=/dev/nfs nfsroot=\${NFSROOT} ip=dhcp; booti 0x48080000 - 0x48000000' ${NC}"
	echo -e "${YELLOW} => run bootnfs ${NC}"
	echo ""
}

##########################################################
sudo umount mnt || true
mkdir -p mnt && sudo rm -rfv mnt/*
if [ ! -e Renesas_software/RTK0EF0045Z0024AZJ-v3.0.0-update2.zip ]; then
	echo -e ${YELLOW}'Please download the RTK0EF0045Z0024AZJ-v3.0.0-update2.zip from renesas.com . '${NC}
	exit 1
fi
if [ ! -e Renesas_software/RTK0EF0045Z13001ZJ-v1.21_EN.zip ]; then
	echo -e ${YELLOW}'Please download the RTK0EF0045Z13001ZJ-v1.21_EN.zip from renesas.com . '${NC}
	exit 1
fi
if [ ! -e Renesas_software/RTK0EF0045Z15001ZJ-v0.58_EN.zip ]; then
	echo -e ${YELLOW}'Please download the RTK0EF0045Z15001ZJ-v0.58_EN.zip from renesas.com . '${NC}
	exit 1
fi

##########################################################
sudo chown -R ${USER}.${USER} Renesas_software meta-userboard* build.sh

##########################################################
sudo apt-get install -y gawk wget git-core diffstat unzip texinfo gcc-multilib \
	build-essential chrpath socat libsdl1.2-dev xterm python-crypto cpio python python3 \
	python3-pip python3-pexpect xz-utils debianutils iputils-ping libssl-dev p7zip-full libyaml-dev \
	nfs-kernel-server parted ffmpeg
echo ""

##########################################################
mkdir -p ${SCRIP_DIR}/sources
cd ${SCRIP_DIR}/sources
echo -e ${GREEN}'>> RZ/G Verified Linux Package V3.0.0-update2'${NC}
[ ! -d ../Renesas_software/RTK0EF0045Z0024AZJ-v3.0.0-update2 ] && \
	unzip -o ../Renesas_software/RTK0EF0045Z0024AZJ-v3.0.0-update2.zip -d ../Renesas_software
if [ ! -d meta-renesas -o ! -d poky -o ! -d meta-openembedded -o ! -d meta-qt5 ]; then
	tar zxvf ../Renesas_software/RTK0EF0045Z0024AZJ-v3.0.0-update2/rzv_bsp_v3.0.0.tar.gz
	patch -p1 -l -f --fuzz 3 -i ../Renesas_software/RTK0EF0045Z0024AZJ-v3.0.0-update2/rzv_v300-to-v300update2.patch
fi

echo -e ${GREEN}'>> RZ MPU Graphics Library Evaluation Version V1.21 for RZ/G2L, RZ/G2LC, and RZ/V2L'${NC}
[ ! -d ../Renesas_software/RTK0EF0045Z13001ZJ-v1.21_EN ] && \
	unzip -o ../Renesas_software/RTK0EF0045Z13001ZJ-v1.21_EN.zip -d ../Renesas_software
[ ! -e meta-rz-features/recipes-graphics/mali/mali-library.bb ] && \
	tar zxvf ../Renesas_software/RTK0EF0045Z13001ZJ-v1.21_EN/meta-rz-features.tar.gz

echo -e ${GREEN}'>> RZ MPU Video Codec Library Evaluation Version V0.58 for RZ/G2L and RZ/V2L'${NC}
[ ! -d ../Renesas_software/RTK0EF0045Z15001ZJ-v0.58_EN ] && \
	unzip -o ../Renesas_software/RTK0EF0045Z15001ZJ-v0.58_EN.zip -d ../Renesas_software
[ ! -e meta-rz-features/recipes-codec/omx-module/omx-user-module.bb ] && \
	tar zxvf ../Renesas_software/RTK0EF0045Z15001ZJ-v0.58_EN/meta-rz-features.tar.gz

##########################################################
cd ${SCRIP_DIR}/sources
echo -e ${GREEN}'>> meta-python2 '${NC}
git clone git://git.openembedded.org/meta-python2 || true
git -C meta-python2 checkout -b develop 07dca1e54f82a06939df9b890c6d1ce1e3197f75 || true
echo -e ${GREEN}'>> meta-clang '${NC}
git clone https://github.com/kraj/meta-clang || true
git -C meta-clang checkout -b develop e63d6f9abba5348e2183089d6ef5ea384d7ae8d8 || true
echo -e ${GREEN}'>> meta-browser '${NC}
git clone https://github.com/OSSystems/meta-browser || true
git -C meta-browser checkout -b develop dcfb4cedc238eee8ed9bd6595bdcacf91c562f67 || true
echo -e ${GREEN}'>> meta-browser '${NC}
git clone https://github.com/xlloss/meta-gnk-board.git || true
git -C meta-gnk-board checkout -b develop 1dd69239e0bf6f994f025d8166c3c0cbca54cf6b || true
sed 's/^BBFILE_COLLECTIONS/#BBFILE_COLLECTIONS/g' -i meta-gnk-board/conf/layer.conf
sed 's/^BBFILE_PATTERN/#BBFILE_PATTERN/g' -i meta-gnk-board/conf/layer.conf
sed 's/^BBFILE_PRIORITY/#BBFILE_PRIORITY/g' -i meta-gnk-board/conf/layer.conf

##########################################################
cd ${SCRIP_DIR}
echo -e ${GREEN}'>> oe-init-build-env '${NC}
source sources/poky/oe-init-build-env ${BUILD_DIR}
echo ""

##########################################################
cd ${SCRIP_DIR}/${BUILD_DIR}
echo -e ${GREEN}'>> local.conf bblayers.conf '${NC}
/bin/cp -fv ../meta-userboard-g2l/docs/template/conf/${TARGET_BOARD}/local.conf ./conf/local.conf
/bin/cp -fv ../meta-userboard-g2l/docs/template/conf/${TARGET_BOARD}/bblayers.conf ./conf/bblayers.conf
/bin/cp -Rpfv ../meta-userboard-g2l/conf/machine/${TARGET_BOARD}.conf ../sources/meta-renesas/conf/machine
echo ""

##########################################################
echo -e ${GREEN}'>> show-layers '${NC}
bitbake-layers show-layers
echo ""
echo -e ${GREEN}'>> core-image '${NC}
cd ${SCRIP_DIR}/${BUILD_DIR}
bitbake ${CORE_IMAGE} -v
#bitbake ${CORE_IMAGE} -v -c populate_sdk
echo ""

##########################################################
cd ${SCRIP_DIR}
print_boot_example
exit 0

