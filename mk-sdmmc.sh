#!/bin/bash -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

WORK=`pwd`/${TARGET_BOARD}

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

SDDEV=${SCRIP_DIR}/build_${TARGET_BOARD}/tmp/deploy/images/${TARGET_BOARD}/SDMMC.img
TOTAL=8192
PART1=2560

function print_boot_example() {
	echo ""
	echo ">> FOR SD BOOT"
	echo ""
	echo -e "${YELLOW} => dcache off ${NC}"
	echo -e "${YELLOW} => mmc dev 1 ${NC}"
	echo -e "${YELLOW} => ext4load mmc 1:1 0x0001FF80 rzv2l_cm33_rpmsg_demo_secure_vector.bin ${NC}"
	echo -e "${YELLOW} => ext4load mmc 1:1 0x42EFF440 rzv2l_cm33_rpmsg_demo_secure_code.bin ${NC}"
	echo -e "${YELLOW} => ext4load mmc 1:1 0x00010000 rzv2l_cm33_rpmsg_demo_non_secure_vector.bin ${NC}"
	echo -e "${YELLOW} => ext4load mmc 1:1 0x40010000 rzv2l_cm33_rpmsg_demo_non_secure_code.bin ${NC}"
	echo -e "${YELLOW} => cm33 start_debug 0x1001FF80 0x00010000 ${NC}"
	echo -e "${YELLOW} => dcache on ${NC}"
	echo ""
	echo -e "${YELLOW} => setenv bootargs rw rootwait ipv6.disable=1 earlycon root=/dev/mmcblk1p2 ${NC}"
	echo -e "${YELLOW} => setenv bootcmd 'ext4load mmc 1:1 0x48080000 Image; ext4load mmc 1:1 0x48000000 ${SOC_FAMILY_PLUS}-${TARGET_BOARD}.dtb; booti 0x48080000 - 0x48000000' ${NC}"
	echo -e "${YELLOW} => saveenv ${NC}"
	echo ""
	echo -e "${YELLOW} root@smarc-rzv2l:~# rpmsg_sample_client 0 ${NC}"
	echo ""
}

function make_rootfs_dir () {
        sudo rm -rf rootfs && mkdir -p rootfs
        sudo tar zxvf build_${1}/tmp/deploy/images/${1}/core-image-${HMI}-${1}.tar.gz -C rootfs
        sudo tar zxvf build_${1}/tmp/deploy/images/${1}/modules-${1}.tgz -C rootfs
        sudo cp -Rpf build_${1}/tmp/deploy/images/${1}/Image* rootfs/boot
        sudo cp -Rpf build_${1}/tmp/deploy/images/${1}/*.dtb rootfs/boot
        sudo cp -Rpf build_${1}/tmp/deploy/images/${1}/rzv2l_cm33_rpmsg_demo_*.bin rootfs/boot
        sudo cp -Rpf build_${1}/tmp/deploy/images/${1}/core-image-${HMI}-*${1}*.tar.gz rootfs/boot
        sudo cp -Rpf build_${1}/tmp/deploy/images/${1}/modules-*${1}*.tgz rootfs/boot
        sudo chmod go+rwx rootfs/home/root

	if [ -d /tftpboot ]; then
		 cp -Rpfv build_${1}/tmp/deploy/images/${1}/Image* /tftpboot
		 cp -Rpfv build_${1}/tmp/deploy/images/${1}/*.dtb /tftpboot
	fi
}

function Usage () {
	echo "Usage: $0 \${TARGET_BOARD_NAME}"
	echo "BOARD_NAME list: "
	for i in ${BOARD_LIST[@]}; do echo "  - $i"; done
	exit 0
}

# Check Param.
if ! `IFS=$'\n'; echo "${BOARD_LIST[*]}" | grep -qx "${TARGET_BOARD}"`; then
	Usage
fi
if [ ! -e ${SCRIP_DIR}/build_${TARGET_BOARD}/tmp/deploy/images/${TARGET_BOARD}/${CORE_IMAGE}-${TARGET_BOARD}.tar.gz ]; then
	Usage
fi
if [ ! -e ${SCRIP_DIR}/build_${TARGET_BOARD}/tmp/deploy/images/${TARGET_BOARD}//modules-${TARGET_BOARD}.tgz ]; then
	Usage
fi
if [ ! -e ${SCRIP_DIR}/build_${TARGET_BOARD}/tmp/deploy/images/${TARGET_BOARD}/Image ]; then
	Usage
fi

##############################
sudo umount mnt || true
sudo rm -rfv mnt && mkdir -p mnt

##############################
make_rootfs_dir ${TARGET_BOARD}

##############################
sudo losetup -D
PART1=$(echo "${PART1} - 1" | bc)

dd if=/dev/zero of=${SDDEV} bs=1M count=${TOTAL} status=progress
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk ${SDDEV}
 n
 p
 1

 +${PART1}M
 n
 p
 2


 t
 1
 83
 t
 2
 83
 p
 w
 q
EOF

##############################
sudo losetup -Pf ${SDDEV}

LOOP=$(losetup | grep SDMMC | awk '{print $1}')
echo y | sudo mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=1 ${LOOP}p1 -L boot -jDv
sudo mount ${LOOP}p1 mnt
sudo cp -Rpf ${SCRIP_DIR}/build_${TARGET_BOARD}/tmp/deploy/images/${TARGET_BOARD}/Image* mnt
sudo cp -Rpf ${SCRIP_DIR}/build_${TARGET_BOARD}/tmp/deploy/images/${TARGET_BOARD}/*.dtb mnt
sudo cp -Rpf ${SCRIP_DIR}/build_${TARGET_BOARD}/tmp/deploy/images/${TARGET_BOARD}/rzv2l_cm33_rpmsg_demo_*.bin mnt
sudo cp -Rpf ${SCRIP_DIR}/build_${TARGET_BOARD}/tmp/deploy/images/${TARGET_BOARD}/${CORE_IMAGE}-${TARGET_BOARD}*.tar.gz mnt
sudo cp -Rpf ${SCRIP_DIR}/build_${TARGET_BOARD}/tmp/deploy/images/${TARGET_BOARD}/modules-*.tgz mnt
sudo umount mnt

echo y | sudo mkfs.ext4 -E lazy_itable_init=0,lazy_journal_init=1 ${LOOP}p2 -L rootfs -U 614e0000-0000-4b53-8000-1d28000054a9 -jDv
sudo mount ${LOOP}p2 mnt
sudo tar zxf ${SCRIP_DIR}/build_${TARGET_BOARD}/tmp/deploy/images/${TARGET_BOARD}/${CORE_IMAGE}-${TARGET_BOARD}.tar.gz -C mnt
sudo tar zxf ${SCRIP_DIR}/build_${TARGET_BOARD}/tmp/deploy/images/${TARGET_BOARD}/modules-${TARGET_BOARD}.tgz -C mnt
sudo umount mnt

sudo losetup -D

##############################
ls -l --color ${SDDEV}
print_boot_example
exit 0
