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
	echo -e "${YELLOW} => setenv bootnfs 'tftp 0x48080000 Image; tftp 0x48000000 ${SOC_FAMILY_PLUS}-${TARGET_BOARD}.dtb; setenv bootargs rw rootwait earlycon root=/dev/nfs nfsroot=\${NFSROOT} ip=dhcp; booti 0x48080000 - 0x48000000' ${NC}"
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
	nfs-kernel-server parted ffmpeg patchelf default-jdk iproute2 python3-serial libftdi-dev ccache python3-git python3-jinja2 libegl1-mesa pylint3
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

#echo -e ${GREEN}'>> RZ/G Verified Linux Package V3.0.2'${NC}
#[ ! -d ../Renesas_software/RTK0EF0045Z0024AZJ-v3.0.2 ] && \
#	(mkdir -p ../Renesas_software/RTK0EF0045Z0024AZJ-v3.0.2 && unzip -o ../Renesas_software/RTK0EF0045Z0024AZJ-v3.0.2.zip -d ../Renesas_software/RTK0EF0045Z0024AZJ-v3.0.2)
#if [ ! -d meta-renesas -o ! -d poky -o ! -d meta-openembedded -o ! -d meta-qt5 ]; then
#	tar zxvf ../Renesas_software/RTK0EF0045Z0024AZJ-v3.0.2/rzv_bsp_v3.0.2.tar.gz
#fi
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

if [ ! -e Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg/meta-rz-features.tar.gz ]; then
	unzip -o ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg.zip -d ../Renesas_software
	unzip -o ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg/rzv2l_cm33_rpmsg_demo.zip -d ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg
	tar zxvf ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg/meta-rz-features.tar.gz
fi

if [ "${TARGET_BOARD}" == "smarc-rzv2l" -o "${TARGET_BOARD}" == "rzv2l-dev" -o "${TARGET_BOARD}" == "gnk-rzv2l" ]; then
	echo -e ${GREEN}'>> r11an0549ej0720-rzv2l-drpai-sp.zip'${NC}
	if [ ! -e ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-driver/meta-rz-features.tar.gz \
		-o ! -e ../meta-userboard-g2l/recipes-demo/app-hrnet-cam/app_hrnet_cam \
		-o ! -e ../meta-userboard-g2l/recipes-demo/app-hrnet-pre-tinyyolov2-cam/app_hrnet_pre-tinyyolov2_cam \
		-o ! -e ../meta-userboard-g2l/recipes-demo/app-resnet50-cam/app_resnet50_cam \
		-o ! -e ../meta-userboard-g2l/recipes-demo/app-resnet50-img/app_resnet50_img \
		-o ! -e ../meta-userboard-g2l/recipes-demo/app-tinyyolov2-cam/app_tinyyolov2_cam \
		-o ! -e ../meta-userboard-g2l/recipes-demo/app-tinyyolov2-isp/app_tinyyolov2_isp \
		-o ! -e ../meta-userboard-g2l/recipes-demo/app-yolo-img/app_yolo_img ]; then

		unzip -o ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp.zip -d ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp
		tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-driver/meta-rz-features.tar.gz
		tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/rzv2l_drpai-sample-application_ver7.20.tar.gz -C ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application
		tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide/rzv_ai-implementation-guide_ver7.20.tar.gz -C ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide
		cp -Rpfv ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/app_hrnet_cam ../meta-userboard-g2l/recipes-demo/app-hrnet-cam
		cp -Rpfv ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/app_hrnet_pre-tinyyolov2_cam ../meta-userboard-g2l/recipes-demo/app-hrnet-pre-tinyyolov2-cam
		cp -Rpfv ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/app_resnet50_cam ../meta-userboard-g2l/recipes-demo/app-resnet50-cam
		cp -Rpfv ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/app_resnet50_img ../meta-userboard-g2l/recipes-demo/app-resnet50-img
		cp -Rpfv ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/app_tinyyolov2_cam ../meta-userboard-g2l/recipes-demo/app-tinyyolov2-cam
		cp -Rpfv ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/app_tinyyolov2_isp ../meta-userboard-g2l/recipes-demo/app-tinyyolov2-isp
		cp -Rpfv ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/app_yolo_img ../meta-userboard-g2l/recipes-demo/app-yolo-img
	fi

	echo -e ${GREEN}'>> r20ut5035ej0180-drp-ai-translator.zip'${NC}
	if [ ! -e ../Renesas_software/drp-ai-translator/DRP-AI_Translator-v1.80-Linux-x86_64-Install -o ! -e ../drp-ai_translator_release/pytorch/resnet50/convert_to_onnx.py ]; then
		unzip -o ../Renesas_software/r20ut5035ej0180-drp-ai-translator.zip -d ../Renesas_software/drp-ai-translator
		chmod +x ../Renesas_software/drp-ai-translator/DRP-AI_Translator-v1.80-Linux-x86_64-Install
		cd ..
		echo y | Renesas_software/drp-ai-translator/DRP-AI_Translator-v1.80-Linux-x86_64-Install
		cd -

		tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide/pytorch_resnet/pytorch_resnet_ver7.20.tar.gz -C ../drp-ai_translator_release
		tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide/mmpose_hrnet/mmpose_hrnet_ver7.20.tar.gz -C ../drp-ai_translator_release
		tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide/darknet_yolo/darknet_yolo_ver7.20.tar.gz -C ../drp-ai_translator_release
		tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide/pytorch_mobilenet/pytorch_mobilenet_ver7.20.tar.gz -C ../drp-ai_translator_release
		tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide/pytorch_deeplabv3/pytorch_deeplabv3_ver7.20.tar.gz -C ../drp-ai_translator_release
	fi

	echo -e ${GREEN}'>> r11an0561ej0120-rzv2l-isp-sp.zip'${NC}
	if [ ! -e ../Renesas_software/r11an0561ej0120-rzv2l-isp-sp/meta-rz-features.tar.gz ]; then
		unzip -o ../Renesas_software/r11an0561ej0120-rzv2l-isp-sp.zip -d ../Renesas_software
		#tar zxvf ../Renesas_software/r11an0561ej0120-rzv2l-isp-sp/meta-rz-features.tar.gz
		tar zxvf ../Renesas_software/r11an0561ej0120-rzv2l-isp-sp/rzv2l_isp-adjustment-tool_ver1.20.tar.gz -C ../Renesas_software/r11an0561ej0120-rzv2l-isp-sp
		tar zxvf ../Renesas_software/r11an0561ej0120-rzv2l-isp-sp/rzv2l_isp-sample-application_ver1.20.tar.gz -C ../Renesas_software/r11an0561ej0120-rzv2l-isp-sp
	fi
else
	rm -rfv ../Renesas_software/rzv2l-drpai-sp ../Renesas_software/r11an0561ej0120-rzv2l-isp-sp ../Renesas_software/drp-ai-translator
	rm -rfv meta-rz-features/recipes-drpai
	rm -rfv meta-rz-features/recipes-isp
	rm -rfv meta-rz-features/include/drpai
fi

##########################################################
cd ${SCRIP_DIR}/sources
cp -fv ../meta-userboard-g2l/conf/meta-rz-features-layer.conf meta-rz-features/conf/layer.conf

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

##########################################################
cd ${SCRIP_DIR}/sources
echo -e ${GREEN}'>> meta-gnk-board '${NC}
git clone https://github.com/xlloss/meta-gnk-board.git || true
git -C meta-gnk-board checkout -b develop 6ce09ce5733b1765c3547826816fb081fdbd84b7 || true
git -C meta-gnk-board checkout .
sed 's|userboard|gnk|g' -i meta-gnk-board/conf/layer.conf
sed 's|^BBFILES += "${@|#BBFILES += "${@|g' -i meta-gnk-board/conf/layer.conf
sed 's|^               for layer in BBFILE_COLLECTIONS.split()|#               for layer in BBFILE_COLLECTIONS.split()|g' -i meta-gnk-board/conf/layer.conf

##########################################################
cd ${SCRIP_DIR}
echo -e ${GREEN}'>> oe-init-build-env '${NC}
source sources/poky/oe-init-build-env ${BUILD_DIR}
echo ""

##########################################################
cd ${SCRIP_DIR}/${BUILD_DIR}
echo -e ${GREEN}'>> local.conf bblayers.conf '${NC}
cp -fv ../meta-userboard-g2l/docs/template/conf/${TARGET_BOARD}/local.conf ./conf/local.conf
cp -fv ../meta-userboard-g2l/docs/template/conf/${TARGET_BOARD}/bblayers.conf ./conf/bblayers.conf
cp -Rpfv ../meta-userboard-g2l/conf/machine/${TARGET_BOARD}.conf ../sources/meta-renesas/conf/machine
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

