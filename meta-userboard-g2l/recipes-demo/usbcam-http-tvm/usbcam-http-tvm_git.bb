FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=0ba5044c64ef53cb0189c9546081e228"
LICENSE = "Apache-2.0"

SRCREV = "860d845b87de9564f143b600e39d84e2455d4281"
SRC_URI = " \
	gitsm://github.com/renesas-rz/rzv_drp-ai_tvm.git;protocol=https;branch=main \
	file://tutorial_app \
	file://drpai.h \
	file://preprocess_tvm_v2l \
	file://emotion_fp_onnx \
	file://face_deeppose_pt \
	file://face_deeppose_cpu \
	file://googlenet_onnx \
	file://hrnet_onnx \
	file://hrnetv2_pt \
	file://resnet18_onnx \
	file://resnet18_onnx_cpu \
	file://resnet18_torch \
	file://tinyyolov2_onnx \
	file://tinyyolov3_onnx \
	file://yolov2_onnx \
	file://yolov3_onnx \
	file://ultraface_onnx \
"

inherit autotools cmake cmake-native pkgconfig python3native

DEPENDS += " \
        drpai \
        opencv \
        wayland-protocols \
"

#S = "${WORKDIR}/git/apps"
S = "${WORKDIR}/git/how-to/sample_app/src"
B = "${WORKDIR}/build"

WEBDIR = "${localstatedir}/tvm"

do_configure_prepend() {
	export TVM_ROOT=${WORKDIR}/git
	export TVM_HOME=${TVM_ROOT}/tvm
	export PYTHONPATH=${TVM_HOME}/python:${PYTHONPATH}
	export PRODUCT=V2L
	export TRANSLATOR=${WORKDIR}/../../../../../../drp-ai_translator_release
	export SDK=${WORKDIR}/../../../x86_64-nativesdk-pokysdk-linux/meta-environment-smarc-rzv2l/1.0-r8/sdk/image/usr/local/oe-sdk-hardcoded-buildpath

	cd ${TVM_ROOT}
	bash setup/make_drp_env.sh || true
	cd ${S}

	mkdir -p ${WORKDIR}/git/tvm/include/linux
	cp -fv ${WORKDIR}/drpai.h ${WORKDIR}/git/tvm/include/linux

	#(echo y | /usr/bin/ffmpeg -i etc/sample.bmp -s 640x480 -pix_fmt yuyv422 exe/sample.yuv) || true
	#cd ${TVM_ROOT}/tutorials
	#[ ! -e resnet18-v1-7.onnx ] && wget https://github.com/onnx/models/raw/main/vision/classification/resnet/model/resnet18-v1-7.onnx -v -O resnet18-v1-7.onnx
	#/usr/bin/python3 compile_onnx_model.py resnet18-v1-7.onnx -o resnet18_onnx -s 1,3,224,224 -i data
	#cd -

	sed 's|:3000/ws/|:4000/ws/|g' -i ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/js/websocket_demo.js
	sed 's|"3000", "ws"|"4000", "ws"|g' -i ${WORKDIR}/git/how-to/sample_app/src/main.cpp
}

do_install_class-target () {
	install -d ${D}/${libdir}
	install ${WORKDIR}/git/obj/build_runtime/V2L/libtvm_runtime.so ${D}/${libdir}
	install -d ${D}/home/root/tvm
	install ${WORKDIR}/tutorial_app ${D}/home/root/tvm
	install ${B}/sample_app_drpai_tvm_usbcam_http ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/ultraface_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/yolov3_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/yolov2_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/tinyyolov3_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/tinyyolov2_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/resnet18_torch ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/resnet18_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/resnet18_onnx_cpu ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/hrnetv2_pt ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/hrnet_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/googlenet_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/face_deeppose_pt ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/face_deeppose_cpu ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/emotion_fp_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/preprocess_tvm_v2l ${D}/home/root/tvm

	install ${WORKDIR}/git/how-to/sample_app/exe/coco-labels-2014_2017.txt ${D}/home/root/tvm
	install ${WORKDIR}/git/how-to/sample_app/exe/coco-labels-2014_2017.txt ${D}/home/root/tvm

	install -d ${D}${WEBDIR}/css
        install -d ${D}${WEBDIR}/js
        install -d ${D}${WEBDIR}/libs
        install ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/index.html ${D}${WEBDIR}
        install ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/css/websocket_demo.css ${D}${WEBDIR}/css
        install ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/js/websocket_demo.js ${D}${WEBDIR}/js
        install ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/libs/*.css ${D}${WEBDIR}/libs
        install ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/libs/*.js ${D}${WEBDIR}/libs
}

FILES_${PN} = " \
	/home/root/tvm \
	${WEBDIR} \
"

INSANE_SKIP_${PN} += " file-rdeps rpaths dev-deps dev-elf already-stripped "
INSANE_SKIP_${PN}-dev += " file-rdeps rpaths dev-deps dev-elf already-stripped "
