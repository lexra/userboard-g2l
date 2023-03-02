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
PN=usbcam-http-demo
MODEL=tinyyolov2
IMG_SRC=cam

##########################################################
if [ 0 -eq `python3 -m pip list | grep torch | wc -l` -o 1 -eq `python3 -m pip list | grep torch | wc -l` ]; then
	pip3 uninstall torch torchvision torchaudio -y || true
	pip3 install torch==1.11.0 torchvision==0.12.0+cpu torchaudio==0.11.0+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html
fi

##########################################################
echo -e "${YELLOW} => ${MODEL}.onnx ${NC}"
cd ${DRPAI_TRANSLATOR_RELEASE}/darknet/yolo
python3 convert_to_pytorch.py ${MODEL}
ls -l convert_to_pytorch.py convert_to_onnx.py *.pth
python3 convert_to_onnx.py ${MODEL}
ls -l convert_to_pytorch.py convert_to_onnx.py *.pth
cp -Rpfv d-${MODEL}.onnx ../../onnx/${MODEL}.onnx
cd -

##########################################################
echo ""
echo -e "${YELLOW} => DRP-AI Translate ${NC}"
cd ${DRPAI_TRANSLATOR_RELEASE}
rm -rf output/${MODEL}_${IMG_SRC}
./run_DRP-AI_translator_V2L.sh ${MODEL}_${IMG_SRC} \
	-onnx onnx/${MODEL}.onnx \
	-prepost ../build_smarc-rzv2l/tmp/work/aarch64-poky-linux/${PN}/git-r0/git/usbcam_http_drp-ai/etc/${MODEL}_${IMG_SRC}/prepost_d-${MODEL}.yaml \
	-addr ../build_smarc-rzv2l/tmp/work/aarch64-poky-linux/${PN}/git-r0/git/usbcam_http_drp-ai/etc/${MODEL}_${IMG_SRC}/addrmap_in_d-${MODEL}.yaml
cd -

##########################################################
echo ""
echo -e "${YELLOW} => files/${MODEL}_${IMG_SRC} ${NC}"
rm -rf files/${MODEL}_${IMG_SRC}
/bin/cp -Rpf ${DRPAI_TRANSLATOR_RELEASE}/output/${MODEL}_${IMG_SRC} files/
ls -l --color files/${MODEL}_${IMG_SRC}

exit 0
