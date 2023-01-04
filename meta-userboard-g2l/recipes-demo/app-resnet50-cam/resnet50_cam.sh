#!/bin/bash -e

##########################################################
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

[ ! -x ../../../sources/drp-ai_translator_release/run_DRP-AI_translator_V2L.sh ] && exit 1
[ -x /usr/bin/python3.8 -a -x /usr/bin/x86_64-linux-gnu-python3.8-config ] && sudo ln -sf python3.8 /usr/bin/python3
[ -x /usr/bin/python3.8 -a -x /usr/bin/x86_64-linux-gnu-python3.8-config ] && sudo ln -sf x86_64-linux-gnu-python3.8-config /usr/bin/python3.8-config
[ -x /usr/bin/python3.8 -a -x /usr/bin/x86_64-linux-gnu-python3.8-config ] && sudo ln -sf python3.8-config /usr/bin/python3-config

##########################################################
APP_NAME=app_resnet50_cam
APP_RECIPE=$(echo $APP_NAME | sed 's/_/-/g')
MODEL=resnet50
IMG_SRC=cam

if [ "${MODEL}" == "resnet50" ]; then
	echo -e "${YELLOW} => ${MODEL}.onnx ${NC}"
	cd ../../../sources/drp-ai_translator_release/pytorch/${MODEL}
	rm -rf ${MODEL}.onnx
	python3 convert_to_onnx.py
	cp -Rpfv ./${MODEL}.onnx ../../onnx/
	cd -
fi

##########################################################
echo -e "${YELLOW} => DRP-AI Translate ${NC}"
cd ../../../sources/drp-ai_translator_release
rm -rf output/${MODEL}_${IMG_SRC}
./run_DRP-AI_translator_V2L.sh ${MODEL}_${IMG_SRC} \
	-onnx onnx/${MODEL}.onnx \
	-prepost ../../meta-userboard-g2l/recipes-demo/${APP_RECIPE}/${APP_NAME}/etc/prepost_${MODEL}.yaml \
	-addr ../../meta-userboard-g2l/recipes-demo/${APP_RECIPE}/${APP_NAME}/etc/addrmap_in_${MODEL}.yaml
cd -
/bin/cp -Rpf ../../../sources/drp-ai_translator_release/output/${MODEL}_${IMG_SRC} ${APP_NAME}/exe
ls -l ${APP_NAME}/exe/${MODEL}_${IMG_SRC}
