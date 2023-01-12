#!/bin/sh -e

MACHINE=$(cat /etc/hostname)
MMCBLK=/dev/mmcblk0

[ ! -f /boot/core-image-qt-${MACHINE}.tar.gz ] && exit 0

umount ${MMCBLK}p1 || true
umount ${MMCBLK}p2 || true
umount ${MMCBLK}p3 || true
umount ${MMCBLK}p4 || true
umount ${MMCBLK}p5 || true
umount ${MMCBLK}p6 || true
umount ${MMCBLK}p7 || true
umount ${MMCBLK}p8 || true

wipefs -a -f ${MMCBLK} || true

sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${MMCBLK}
 d

 d

 d

 d

 d

 d

 d

 d

 n
 p
 1

 +128M
 n
 p
 2


 t
 1
 83
 t
 2
 83
 w
EOF
sync
echo yes | mkfs.ext4 -E lazy_itable_init=1,lazy_journal_init=1 ${MMCBLK}p1 -L boot -U 971f7d9a-684d-4f90-80f0-9825f95fcb7a -jDv
echo yes | mkfs.ext4 -E lazy_itable_init=1,lazy_journal_init=1 ${MMCBLK}p2 -L root -U 614e0000-0000-4b53-8000-1d28000054a9 -jDv

mount ${MMCBLK}p2 /mnt
rm -rfv /mnt/*
tar zxvf /boot/core-image-qt-${MACHINE}.tar.gz -C /mnt
tar zxvf /boot/modules-${MACHINE}.tgz -C /mnt
umount /mnt

mount ${MMCBLK}p1 /mnt
rm -rfv /mnt/*
cp -a /boot/Image* /mnt
cp -a /boot/*.dtb /mnt
cp -a /boot/rzv2l_cm33_rpmsg_demo_*.bin /mnt || true
umount /mnt

reboot
