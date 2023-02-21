#!/bin/bash -e

##########################################################
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

DRPAI_TRANSLATOR_RELEASE=../../../drp-ai_translator_release
[ ! -x ${DRPAI_TRANSLATOR_RELEASE}/run_DRP-AI_translator_V2L.sh ] && exit 1
[ ! -e ${DRPAI_TRANSLATOR_RELEASE}/pytorch/resnet50/convert_to_onnx.py ] && exit 1

##########################################################
APP_NAME=Face_spoof_detection_img
APP_RECIPE=$(echo $APP_NAME | sed 's/_/-/g')
MODEL=resnet50
IMG_SRC=classifier_bmp

##########################################################
if [ 0 -eq `python3 -m pip list | grep torch | wc -l` -o 1 -eq `python3 -m pip list | grep torch | wc -l` ]; then
	pip3 uninstall torch torchvision torchaudio -y || true
	pip3 install torch==1.11.0 torchvision==0.12.0+cpu torchaudio==0.11.0+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html
fi

##########################################################
if [ "${MODEL}" == "resnet50" ]; then
	echo -e "${YELLOW} => ${MODEL}.onnx ${NC}"
	cd ${DRPAI_TRANSLATOR_RELEASE}/pytorch/${MODEL}
	python3 convert_to_onnx.py
	cp -Rpfv ./${MODEL}.onnx ../../onnx
	cd -
fi

##########################################################
echo ""
echo -e "${YELLOW} => DRP-AI Translate ${NC}"
cd ${DRPAI_TRANSLATOR_RELEASE}
rm -rf output/${MODEL}_${IMG_SRC}
./run_DRP-AI_translator_V2L.sh ${MODEL}_${IMG_SRC} \
	-onnx onnx/${MODEL}.onnx \
	-prepost ../meta-userboard-g2l/recipes-demo/rzv-face-dection/files/${APP_NAME}/etc/prepost_${MODEL}.yaml \
	-addr ../meta-userboard-g2l/recipes-demo/rzv-face-dection/files/${APP_NAME}/etc/addrmap_in_${MODEL}.yaml
cd -

##########################################################
echo ""
echo -e "${YELLOW} => ${APP_NAME}/exe/${MODEL}_${IMG_SRC} ${NC}"
rm -rf ${APP_NAME}/exe/${MODEL}_${IMG_SRC}
/bin/cp -Rpf ${DRPAI_TRANSLATOR_RELEASE}/output/${MODEL}_${IMG_SRC} files/${APP_NAME}/exe
ls -l --color files/${APP_NAME}/exe/${MODEL}_${IMG_SRC}

exit 0
