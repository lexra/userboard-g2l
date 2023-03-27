#!/bin/bash -e

##########################################################
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

WORK=`pwd`
DRP_SUPPORT_PACKAGE=r11an0549ej0730-rzv2l-drpai-sp
DRPAI_TRANSLATOR_RELEASE=${WORK}/../../../drp-ai_translator_release
[ ! -x ${DRPAI_TRANSLATOR_RELEASE}/run_DRP-AI_translator_V2L.sh ] && exit 1
[ ! -e ${DRPAI_TRANSLATOR_RELEASE}/pytorch/resnet50/convert_to_onnx.py ] && exit 1

##########################################################
PN=usbcam-http-demo
MODEL=hrnet
IMG_SRC=cam

#############################
mkdir -p ${DRPAI_TRANSLATOR_RELEASE}/hrnet
cd ${DRPAI_TRANSLATOR_RELEASE}/hrnet
git clone https://github.com/open-mmlab/mmpose.git || true
#git -C mmpose checkout v0.28.1 || true
cd mmpose
git checkout tools/deployment/pytorch2onnx.py
patch -p1 -l -f --fuzz 3 -i ../../../extra/mmpose_tools_deployment_pytorch2onnx_py.patch

PYTHONPATH=`pwd`:${PYTHONPATH}
NN=configs/body/2d_kpt_sview_rgb_img/topdown_heatmap/coco/hrnet_w32_coco_256x192.py
OUTPUT=${MODEL}.onnx
WEIGHT=hrnet_w32_coco_256x192-c78dce93_20200708.pth
[ ! -f ${WEIGHT} ] && wget https://download.openmmlab.com/mmpose/top_down/${MODEL}/${WEIGHT} -O ${WEIGHT}
python3 tools/deployment/pytorch2onnx.py $NN $WEIGHT --opset-version 11 --shape 1 3 256 192 --output-file $OUTPUT
cp -Rpfv ${MODEL}.onnx ../../onnx/${MODEL}.onnx

##########################################################
echo ""
echo -e "${YELLOW} => DRP-AI Translate ${NC}"
cd ${DRPAI_TRANSLATOR_RELEASE}
rm -rf output/${MODEL}_${IMG_SRC}
./run_DRP-AI_translator_V2L.sh ${MODEL}_${IMG_SRC} \
	-onnx onnx/${MODEL}.onnx \
	-prepost ../Renesas_software/${DRP_SUPPORT_PACKAGE}/rzv2l_drpai-sample-application/app_usbcam_http/etc/${MODEL}_${IMG_SRC}/prepost_${MODEL}.yaml \
	-addr    ../Renesas_software/${DRP_SUPPORT_PACKAGE}/rzv2l_drpai-sample-application/app_usbcam_http/etc/${MODEL}_${IMG_SRC}/addrmap_in_${MODEL}.yaml
cd ${WORK}

##########################################################
echo ""
echo -e "${YELLOW} => files/${MODEL}_${IMG_SRC} ${NC}"
rm -rf files/${MODEL}_${IMG_SRC}
/bin/cp -Rpf ${DRPAI_TRANSLATOR_RELEASE}/output/${MODEL}_${IMG_SRC} files/
ls -l --color files/${MODEL}_${IMG_SRC}

exit 0
