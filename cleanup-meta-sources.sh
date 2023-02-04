#!/bin/bash -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

[ ! -d Renesas_software ] && exit 1

cd Renesas_software
find . -type d | xargs sudo rm -rfv || true
cd -
sudo rm -rfv sources mnt drp-ai_translator_release drp-ai_tvm \
	meta-userboard-g2l/recipes-demo/app-hrnet-cam/app_hrnet_cam \
	meta-userboard-g2l/recipes-demo/app-hrnet-pre-tinyyolov2-cam/app_hrnet_pre-tinyyolov2_cam \
	meta-userboard-g2l/recipes-demo/app-resnet50-cam/app_resnet50_cam \
	meta-userboard-g2l/recipes-demo/app-resnet50-img/app_resnet50_img \
	meta-userboard-g2l/recipes-demo/app-tinyyolov2-cam/app_tinyyolov2_cam \
	meta-userboard-g2l/recipes-demo/app-yolo-img/app_yolo_img \
	meta-userboard-g2l/recipes-demo/app-tinyyolov2-isp/app_tinyyolov2_isp \

exit 0
