#!/bin/bash -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

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

cd Renesas_software
find . -type d | xargs rm -rfv || true
cd -
rm -rfv sources mnt drp-ai_translator_release \
	meta-userboard-g2l/recipes-demo/app-hrnet-cam/app_hrnet_cam \
	meta-userboard-g2l/recipes-demo/app-hrnet-pre-tinyyolov2-cam/app_hrnet_pre-tinyyolov2_cam \
	meta-userboard-g2l/recipes-demo/app-resnet50-cam/app_resnet50_cam \
	meta-userboard-g2l/recipes-demo/app-resnet50-img/app_resnet50_img \
	meta-userboard-g2l/recipes-demo/app-tinyyolov2-cam/app_tinyyolov2_cam \
	meta-userboard-g2l/recipes-demo/app-yolo-img/app_yolo_img \
	meta-userboard-g2l/recipes-demo/app-tinyyolov2-isp/app_tinyyolov2_isp \

exit 0
