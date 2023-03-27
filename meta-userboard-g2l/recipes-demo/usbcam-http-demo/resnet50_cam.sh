#!/bin/bash -e

##########################################################
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

DRP_SUPPORT_PACKAGE=r11an0549ej0730-rzv2l-drpai-sp
DRPAI_TRANSLATOR_RELEASE=../../../drp-ai_translator_release
[ ! -x ${DRPAI_TRANSLATOR_RELEASE}/run_DRP-AI_translator_V2L.sh ] && exit 1
[ ! -e ${DRPAI_TRANSLATOR_RELEASE}/pytorch/resnet50/convert_to_onnx.py ] && exit 1

##########################################################
PN=usbcam-http-demo
MODEL=resnet50
IMG_SRC=cam

##########################################################
echo -e "${YELLOW} => ${MODEL}.onnx ${NC}"
cd ${DRPAI_TRANSLATOR_RELEASE}/pytorch/${MODEL}
python3 convert_to_onnx.py
cp -Rpfv ./${MODEL}.onnx ../../onnx
cd -

##########################################################
echo ""
echo -e "${YELLOW} => DRP-AI Translate ${NC}"
cd ${DRPAI_TRANSLATOR_RELEASE}
rm -rf output/${MODEL}_${IMG_SRC}
./run_DRP-AI_translator_V2L.sh ${MODEL}_${IMG_SRC} \
	-onnx onnx/${MODEL}.onnx \
	-prepost ../Renesas_software/${DRP_SUPPORT_PACKAGE}/rzv2l_drpai-sample-application/app_usbcam_http/etc/${MODEL}_${IMG_SRC}/prepost_${MODEL}.yaml \
	-addr    ../Renesas_software/${DRP_SUPPORT_PACKAGE}/rzv2l_drpai-sample-application/app_usbcam_http/etc/${MODEL}_${IMG_SRC}/addrmap_in_${MODEL}.yaml
cd -

##########################################################
echo ""
echo -e "${YELLOW} => files/${MODEL}_${IMG_SRC} ${NC}"
rm -rf files/${MODEL}_${IMG_SRC}
/bin/cp -Rpf ${DRPAI_TRANSLATOR_RELEASE}/output/${MODEL}_${IMG_SRC} files/
ls -l --color files/${MODEL}_${IMG_SRC}

exit 0
