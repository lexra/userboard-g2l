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
APP_NAME=app_resnet50_img
APP_RECIPE=$(echo $APP_NAME | sed 's/_/-/g')
MODEL=resnet50
IMG_SRC=bmp

##########################################################
NEED_RESTORE=0
if [ -x /usr/bin/python3.8 -a -x /usr/bin/x86_64-linux-gnu-python3.8-config -a "$(lsb_release -a | grep 'Release:' | awk '{print $2}')" == ""18.04 ]; then
	echo -e "${YELLOW} => update python3 to python3.8 ${NC}"
	echo ""
	sudo ln -sf python3.8 /usr/bin/python3
	sudo ln -sf x86_64-linux-gnu-python3.8-config /usr/bin/python3.8-config
	sudo ln -sf python3.8-config /usr/bin/python3-config
	NEED_RESTORE=1
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
	-prepost ../meta-userboard-g2l/recipes-demo/${APP_RECIPE}/${APP_NAME}/etc/prepost_${MODEL}.yaml \
	-addr ../meta-userboard-g2l/recipes-demo/${APP_RECIPE}/${APP_NAME}/etc/addrmap_in_${MODEL}.yaml
cd -

##########################################################
echo ""
echo -e "${YELLOW} => ${APP_NAME}/exe/${MODEL}_${IMG_SRC} ${NC}"
rm -rf ${APP_NAME}/exe/${MODEL}_${IMG_SRC}
/bin/cp -Rpf ${DRPAI_TRANSLATOR_RELEASE}/output/${MODEL}_${IMG_SRC} ${APP_NAME}/exe
ls -l --color ${APP_NAME}/exe/${MODEL}_${IMG_SRC}

##########################################################
if [ -x /usr/bin/python3.6 -a -x /usr/bin/x86_64-linux-gnu-python3.6-config -a 1 -eq ${NEED_RESTORE} ]; then
	echo ""
	echo -e "${YELLOW} => restore python3 to default ${NC}"
	sudo ln -sf python3.6 /usr/bin/python3
	sudo ln -sf x86_64-linux-gnu-python3.6-config /usr/bin/python3.6-config
	sudo ln -sf python3.6-config /usr/bin/python3-config
fi

exit 0
