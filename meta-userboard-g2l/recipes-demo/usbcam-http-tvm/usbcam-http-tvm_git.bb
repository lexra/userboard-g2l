FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=0ba5044c64ef53cb0189c9546081e228"
LICENSE = "Apache-2.0"

SVC = "thttpd-tvm"
SRCREV = "860d845b87de9564f143b600e39d84e2455d4281"
SRC_URI = " \
	gitsm://github.com/renesas-rz/rzv_drp-ai_tvm.git;protocol=https;branch=main \
	file://make_drp_env.sh \
	file://face_deeppose_pt \
	file://googlenet_onnx \
	file://hrnet_onnx \
	file://hrnetv2_pt \
	file://resnet18_onnx \
	file://resnet18_onnx_cpu \
	file://resnet18_torch \
	file://resnet18_reference \
	file://tinyyolov2_onnx \
	file://tinyyolov3_onnx \
	file://yolov2_onnx \
	file://yolov3_onnx \
	file://ultraface_onnx \
	file://emotion_fp_onnx \
	file://${SVC}.sh \
	file://${SVC}.service \
	file://index.html \
"

SYSTEMD_SERVICE_${SVC}= "${SVC}.service"
SYSTEMD_AUTO_ENABLE = "disable"

inherit autotools cmake pkgconfig python3native systemd

DEPENDS += " \
	drpai \
	opencv \
	wayland-protocols \
"

EXTRA_OECMAKE = " -DCMAKE_FIND_ROOT_PATH=${STAGING_DIR_TARGET} -DMERA_DRP_RUNTIME=ON -DDCMAKE_SYSTEM_VERSION=1 -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_VERBOSE_MAKEFILE=ON"

S = "${WORKDIR}/git/how-to/sample_app/src"
B = "${WORKDIR}/gir/how-to/sample_app/src/toolchain"

WEBDIR = "${localstatedir}/tvm"

do_configure_prepend () {
	export TVM_ROOT=${WORKDIR}/git
	export TVM_HOME=${TVM_ROOT}/tvm
	export PRODUCT=V2L

	cd ${TVM_ROOT}
	cp -Rpfv ${WORKDIR}/make_drp_env.sh setup/
	bash setup/make_drp_env.sh
	cd ${S}

	mkdir -p ${WORKDIR}/git/tvm/include/linux
	cp -fv ${STAGING_DIR_TARGET}/usr/include/linux/drpai.h ${WORKDIR}/git/tvm/include/linux

	sed 's|192.168.1.11:3000/ws/|192.168.1.111:4000/ws/|' -i ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/js/websocket_demo.js
	sed 's|"192.168.1.11", "3000", "ws"|"192.168.1.111", "4000", "ws"|' -i ${WORKDIR}/git/how-to/sample_app/src/main.cpp

	sed 's|"addr_map_start": 0x438E0000,|"addr_map_start": 0x838E0000,|' -i ${WORKDIR}/git/tutorials/compile_onnx_model.py
	sed 's|"addr_map_start": 0x438E0000,|"addr_map_start": 0x838E0000,|' -i ${WORKDIR}/git/tutorials/compile_pytorch_model.py

	sed 's|preprocess_tvm_v2ma|preprocess_tvm_v2l|' -i ${WORKDIR}/git/how-to/sample_app/src/recognize/yolo/tvm_drpai_yolo.h
	sed 's|preprocess_tvm_v2ma|preprocess_tvm_v2l|' -i ${WORKDIR}/git/how-to/sample_app/src/recognize/googlenet/tvm_drpai_googlenet.h
	sed 's|preprocess_tvm_v2ma|preprocess_tvm_v2l|' -i ${WORKDIR}/git/how-to/sample_app/src/recognize/deeppose/tvm_drpai_deeppose.h
	sed 's|preprocess_tvm_v2ma|preprocess_tvm_v2l|' -i ${WORKDIR}/git/how-to/sample_app/src/recognize/hrnet/tvm_drpai_hrnet.h
	sed 's|preprocess_tvm_v2ma|preprocess_tvm_v2l|' -i ${WORKDIR}/git/how-to/sample_app/src/recognize/ultraface/tvm_drpai_ultraface.h

	sed 's|runtime.SetInput(0, pre_output_ptr);$|runtime.SetInput(0, pre_output_ptr); runtime.ProfileRun("profile_table.txt", "profile.csv");|' -i ${WORKDIR}/git/how-to/sample_app/src/recognize/recognize_base.cpp
}

do_compile_append () {
	export TVM_ROOT=${WORKDIR}/git
	export TVM_HOME=${TVM_ROOT}/tvm
	export PRODUCT=V2L

	mkdir -p ${WORKDIR}/git/apps/toolchain
	cd ${WORKDIR}/git/apps/toolchain
	cmake ..
	oe_runmake VERBOSE=1
	cd -

	cp ${WORKDIR}/git/apps/MeraDrpRuntimeWrapper.cpp ${WORKDIR}/git/how-to/tips/compare_difference/apps
	cp ${WORKDIR}/git/apps/MeraDrpRuntimeWrapper.h ${WORKDIR}/git/how-to/tips/compare_difference/apps
	cp ${WORKDIR}/git/apps/PreRuntime.cpp ${WORKDIR}/git/how-to/tips/compare_difference/apps
	cp ${WORKDIR}/git/apps/PreRuntime.h ${WORKDIR}/git/how-to/tips/compare_difference/apps
	sed 's|set(TVM_ROOT ${CMAKE_CURRENT_BINARY_DIR}/../../tvm/)|set(TVM_ROOT ${CMAKE_CURRENT_BINARY_DIR}/../../../../../tvm/)|' -i ${WORKDIR}/git/how-to/tips/compare_difference/apps/CMakeLists.txt
	mkdir -p ${WORKDIR}/git/how-to/tips/compare_difference/apps/toolchain
	cd ${WORKDIR}/git/how-to/tips/compare_difference/apps/toolchain
	cmake ..
	oe_runmake VERBOSE=1
	cd -
}

do_install_class-target () {
	install -d ${D}${libdir}
	install ${WORKDIR}/git/obj/build_runtime/V2L/libtvm_runtime.so ${D}${libdir}
	install -d ${D}/home/root/tvm

	install -m 755 ${WORKDIR}/git/apps/toolchain/tutorial_app ${D}/home/root/tvm
	install -m 755 ${WORKDIR}/git/how-to/tips/compare_difference/apps/toolchain/inference_comparison ${D}/home/root/tvm
	install -m 755 ${B}/sample_app_drpai_tvm_usbcam_http ${D}/home/root/tvm
	install -m 644 ${WORKDIR}/git/how-to/tips/profiling/profile_reader.py ${D}/home/root/tvm

	install -m 755 ${WORKDIR}/${SVC}.sh ${D}/home/root/tvm

	cp -Rfv ${WORKDIR}/git/apps/exe/preprocess_tvm_v2l ${D}/home/root/tvm

	cp -Rfv ${WORKDIR}/ultraface_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/yolov3_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/yolov2_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/tinyyolov3_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/tinyyolov2_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/resnet18_torch ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/resnet18_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/hrnetv2_pt ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/hrnet_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/googlenet_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/face_deeppose_pt ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/emotion_fp_onnx ${D}/home/root/tvm
	cp -Rfv ${WORKDIR}/resnet18_reference ${D}/home/root/tvm

	install -m 644 ${WORKDIR}/git/how-to/sample_app/exe/coco-labels-2014_2017.txt ${D}/home/root/tvm
	install -m 644 ${WORKDIR}/git/how-to/sample_app/exe/synset_words_imagenet.txt ${D}/home/root/tvm
	install -m 644 ${WORKDIR}/git/apps/exe/sample.yuv ${D}/home/root/tvm

	install -d ${D}${WEBDIR}/css
        install -d ${D}${WEBDIR}/js
        install -d ${D}${WEBDIR}/libs
        #install -m 644 ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/index.html ${D}${WEBDIR}
        install -m 644 ${WORKDIR}/index.html ${D}${WEBDIR}
        install -m 644 ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/css/*.css ${D}${WEBDIR}/css
        install -m 644 ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/js/*.js ${D}${WEBDIR}/js
        install -m 644 ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/libs/*.css ${D}${WEBDIR}/libs
        install -m 644 ${WORKDIR}/git/how-to/sample_app/etc/Websocket_Client/libs/*.js ${D}${WEBDIR}/libs

	install -d ${D}${nonarch_base_libdir}/systemd/system
	install ${WORKDIR}/${SVC}.service ${D}${nonarch_base_libdir}/systemd/system
}

FILES_${PN} = " \
	${nonarch_base_libdir} \
	${libdir} \
	/home/root/tvm \
	${WEBDIR} \
"

INSANE_SKIP_${PN} += " file-rdeps rpaths dev-deps dev-elf already-stripped "
INSANE_SKIP_${PN}-dev += " file-rdeps rpaths dev-deps dev-elf already-stripped "
