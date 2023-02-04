FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=0ba5044c64ef53cb0189c9546081e228"
LICENSE = "Apache-2.0"

SRCREV = "860d845b87de9564f143b600e39d84e2455d4281"
SRC_URI = " \
	gitsm://github.com/renesas-rz/rzv_drp-ai_tvm.git;protocol=https;branch=main \
	file://* \
"

COMPATIBLE_MACHINE_rzv2l = "(smarc-rzv2l|rzv2l-dev|gnk-rzv2l)"

inherit autotools cmake cmake-native pkgconfig python3native

DEPENDS += " \
        drpai \
        opencv \
        wayland-protocols \
"

S = "${WORKDIR}/git/apps"
B = "${WORKDIR}/build"

do_configure_prepend() {
	export TVM_ROOT=${S}/..
	export TVM_HOME=${S}/../tvm
	export PYTHONPATH=${TVM_HOME}/python:${PYTHONPATH}
	export PRODUCT=V2L
	export TRANSLATOR=${S}/../../../../../../../../drp-ai_translator_release

	cd ${S}/..
	bash setup/make_drp_env.sh || true
	cd -

	mkdir -p ${S}/../tvm/include/linux
	cp -fv ${WORKDIR}/drpai.h ${S}/../tvm/include/linux
	echo y | (ffmpeg -i etc/sample.bmp -s 640x480 -pix_fmt yuyv422 exe/sample.yuv || true)
}

do_install_class-target () {
	install -d ${D}/home/root/tvm/exe/preprocess_tvm_v2l
	install -d ${D}/home/root/tvm/exe/resnet18_onnx
	install -d ${D}/home/root/tvm/etc
	install -d ${D}/${libdir}
	install ${S}/../obj/build_runtime/V2L/libtvm_runtime.so ${D}/${libdir}
	install ${B}/tutorial_app ${D}/home/root/tvm/exe
	install ${S}/exe/preprocess_tvm_v2l/* ${D}/home/root/tvm/exe/preprocess_tvm_v2l
	install ${S}/exe/*.txt ${D}/home/root/tvm/exe
	install ${S}/exe/*.yuv ${D}/home/root/tvm/exe
	install ${WORKDIR}/deploy.json ${D}/home/root/tvm/exe/resnet18_onnx
	install ${WORKDIR}/deploy.params ${D}/home/root/tvm/exe/resnet18_onnx
	install ${WORKDIR}/deploy.so ${D}/home/root/tvm/exe/resnet18_onnx || true
}

FILES_${PN} = " \
        /home/root/tvm \
"

INSANE_SKIP_${PN} += " file-rdeps rpaths dev-deps dev-elf "
INSANE_SKIP_${PN}-dev += " file-rdeps rpaths dev-deps dev-elf "
