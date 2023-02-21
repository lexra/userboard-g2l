#!/bin/bash -e

##########################################################
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

DRPAI_TRANSLATOR_RELEASE=`pwd`/../../../drp-ai_translator_release
[ ! -x ${DRPAI_TRANSLATOR_RELEASE}/run_DRP-AI_translator_V2L.sh ] && exit 1
[ ! -e ${DRPAI_TRANSLATOR_RELEASE}/pytorch/resnet50/convert_to_onnx.py ] && exit 1

##########################################################
APP_NAME=Elderly_fall_detection
#APP_RECIPE=$(echo $APP_NAME | sed 's/_/-/g')
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
	-prepost ../meta-userboard-g2l/recipes-demo/rzv-face-dection/files/${APP_NAME}/etc/prepost_d-${MODEL}.yaml \
	-addr ../meta-userboard-g2l/recipes-demo/rzv-face-dection/files/${APP_NAME}/etc/addrmap_in_d-${MODEL}.yaml
cd -

##########################################################
echo ""
echo -e "${YELLOW} => ${APP_NAME}/exe/${MODEL}_${IMG_SRC} ${NC}"
rm -rf ${APP_NAME}/exe/${MODEL}_${IMG_SRC}
/bin/cp -Rpf ${DRPAI_TRANSLATOR_RELEASE}/output/${MODEL}_${IMG_SRC} files/${APP_NAME}/exe
ls -l --color files/${APP_NAME}/exe/${MODEL}_${IMG_SRC}


#############################
mkdir -p ${DRPAI_TRANSLATOR_RELEASE}/hrnet
cd ${DRPAI_TRANSLATOR_RELEASE}/hrnet
git clone -b v0.18.0 https://github.com/open-mmlab/mmpose.git || true
cd mmpose
git checkout tools/deployment/pytorch2onnx.py && patch -p1 -l -f --fuzz 3 -i ../../../extra/mmpose_tools_deployment_pytorch2onnx_py.patch
if [ ! -e ${DRPAI_TRANSLATOR_RELEASE}/hrnet/mmpose ]; then
	pip3 install -r requirements.txt
	sudo python3 setup.py develop
	(pip3 uninstall opencv_python_headless -y || true) && pip3 install opencv-python-headless==4.5.4.60
	(pip3 uninstall mmcv -y || true) && pip3 install mmcv==1.3.16
fi

MODEL=hrnet
IMG_SRC=cam
NN=configs/body/2d_kpt_sview_rgb_img/topdown_heatmap/coco/hrnet_w32_coco_256x192.py
OUTPUT=${MODEL}.onnx
WEIGHT=hrnet_w32_coco_256x192-c78dce93_20200708.pth
[ ! -f ${WEIGHT} ] && wget https://download.openmmlab.com/mmpose/top_down/${MODEL}/${WEIGHT} -O ${WEIGHT}
pwd
python3 tools/deployment/pytorch2onnx.py $NN $WEIGHT --opset-version 11 --shape 1 3 256 192 --output-file $OUTPUT
cp -Rpfv ${MODEL}.onnx ../../onnx/${MODEL}.onnx

##########################################################
echo ""
echo -e "${YELLOW} => DRP-AI Translate ${NC}"
cd ${DRPAI_TRANSLATOR_RELEASE}
rm -rf output/${MODEL}_${IMG_SRC}
./run_DRP-AI_translator_V2L.sh ${MODEL}_${IMG_SRC} \
	-onnx onnx/${MODEL}.onnx \
	-prepost ../meta-userboard-g2l/recipes-demo/rzv-face-dection/files/${APP_NAME}/etc/prepost_${MODEL}.yaml \
	-addr ../meta-userboard-g2l/recipes-demo/rzv-face-dection/files/${APP_NAME}/etc/addrmap_in_${MODEL}.yaml
cd ${DRPAI_TRANSLATOR_RELEASE}/../meta-userboard-g2l/recipes-demo/rzv-face-dection

##########################################################
echo ""
echo -e "${YELLOW} => ${APP_NAME}/exe/${MODEL}_${IMG_SRC} ${NC}"
rm -rf ${APP_NAME}/exe/${MODEL}_${IMG_SRC}
/bin/cp -Rpf ${DRPAI_TRANSLATOR_RELEASE}/output/${MODEL}_${IMG_SRC} files/${APP_NAME}/exe
ls -l --color files/${APP_NAME}/exe/${MODEL}_${IMG_SRC}

exit 0
