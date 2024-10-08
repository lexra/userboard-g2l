inherit populate_sdk_qt5
TOOLCHAIN_HOST_TASK_append = " nativesdk-qtwayland-tools "
FEATURE_PACKAGES_tools-sdk += " packagegroup-qt5-toolchain-target kernel-devsrc "

TOOLCHAIN_TARGET_TASK_append = " \
	${@oe.utils.conditional("ISP_RECIPES", "True", "isp", "", d)} \
"

FORTRAN_TOOLS = " \
	gfortran \
	gfortran-symlinks \
	libgfortran \
	libgfortran-dev \
"

IMAGE_INSTALL_append = " \
	liboai \
	tslib nfs-utils e2fsprogs e2fsprogs-mke2fs e2fsprogs-resize2fs udev curl bc usbutils wget \
	mmc-utils squashfs-tools iputils sqlite3 libevent \
	devmem2 i2c-tools libgpiod sysbench \
	\
	libdrm-tests libdrm-kms libdrm \
	libpng libjpeg-turbo pv fbida yavta \
	\
	mpg123 libexif giflib mrtg \
	portaudio-v19 ${FORTRAN_TOOLS} \
	dtc \
"

IMAGE_INSTALL_append_smarc-rzv2l = " \
	${@oe.utils.conditional("DRPAI_RECIPES", "True", "app-hrnet-cam app-hrnet-pre-tinyyolov2-cam app-resnet50-cam app-resnet50-img app-tinyyolov2-cam app-yolo-img", "", d)} \
	${@oe.utils.conditional("ISP_RECIPES", "True", "app-tinyyolov2-isp", "", d)} \
	${@oe.utils.conditional("DRPAI_RECIPES", "True", "thttpd usbcam-http-tvm rzv-face-dection", "", d)} \
"
IMAGE_INSTALL_append_rzv2l-dev = " \
	${@oe.utils.conditional("DRPAI_RECIPES", "True", "app-hrnet-cam app-hrnet-pre-tinyyolov2-cam app-resnet50-cam app-resnet50-img app-tinyyolov2-cam app-yolo-img", "", d)} \
	${@oe.utils.conditional("ISP_RECIPES", "True", "app-tinyyolov2-isp", "", d)} \
	${@oe.utils.conditional("DRPAI_RECIPES", "True", "thttpd usbcam-http-tvm rzv-face-dection", "", d)} \
"
IMAGE_INSTALL_append_gnk-rzv2l = " \
	${@oe.utils.conditional("DRPAI_RECIPES", "True", "app-hrnet-cam app-hrnet-pre-tinyyolov2-cam app-resnet50-cam app-resnet50-img app-tinyyolov2-cam app-yolo-img", "", d)} \
	${@oe.utils.conditional("ISP_RECIPES", "True", "app-tinyyolov2-isp", "", d)} \
	${@oe.utils.conditional("DRPAI_RECIPES", "True", "thttpd usbcam-http-tvm rzv-face-dection", "", d)} \
"

IMAGE_INSTALL_append = " \
	cv-capture \
	bayer2raw drm2png \
	mkfs-helper \
	${@bb.utils.contains("DISTRO_FEATURES", "edge-ai", "onnxruntime-benchmark armnn-benchmark tensorflow-lite-benchmark models-onnx models-tensorflow-lite ai-tests mkswap", "", d)} \
	${@bb.utils.contains("DISTRO_FEATURES", "vosk", "python3-vosk-api qvosk vosk vosk-server boost-dev", "", d)} \
	${@oe.utils.conditional("CHROMIUM", "1", "chromium-ozone-wayland", "", d)} \
	${@bb.utils.contains("DISTRO_FEATURES", "wayland", "glmark2", "", d)} \
	lws \
"

rz_update_issues () {
    # Set BSP version
    BSP_VERSION="3.0.2"

    # Set SoC and Board info
    case "${MACHINE}" in
    greenpak-rzv2l)
      BSP_SOC="RZV2L"
      BSP_BOARD="RZV2L-GREENPAK-EVK"
      ;;
    greenpak-rzg2l)
      BSP_SOC="RZG2L"
      BSP_BOARD="RZG2L-GREENPAK-EVK"
      ;;
    smarc-rzg2l)
      BSP_SOC="RZG2L"
      BSP_BOARD="RZG2L-SMARC-EVK"
      ;;
    smarc-rzg2lc)
      BSP_SOC="RZG2LC"
      BSP_BOARD="RZG2LC-SMARC-EVK"
      ;;
    smarc-rzg2ul)
      BSP_SOC="RZG2UL"
      BSP_BOARD="RZG2UL-SMARC-EVK"
      ;;
    smarc-rzv2l)
      BSP_SOC="RZV2L"
      BSP_BOARD="RZV2L-SMARC-EVK"
      ;;
    rzv2l-dev)
      BSP_SOC="RZV2L"
      BSP_BOARD="RZV2L-DEV"
      ;;
    hihope-rzg2h)
      BSP_SOC="RZG2H"
      BSP_BOARD="HIHOPE-RZG2H"
      ;;
    hihope-rzg2m)
      BSP_SOC="RZG2M"
      BSP_BOARD="HIHOPE-RZG2M"
      ;;
    hihope-rzg2n)
      BSP_SOC="RZG2N"
      BSP_BOARD="HIHOPE-RZG2N"
      ;;
    ek874)
      BSP_SOC="RZG2E"
      BSP_BOARD="EK874"
      ;;

    esac

    # Make issue file
    echo "BSP: ${BSP_SOC}/${BSP_BOARD}/${BSP_VERSION}" >> ${IMAGE_ROOTFS}/etc/issue
    echo "LSI: ${BSP_SOC}" >> ${IMAGE_ROOTFS}/etc/issue
    echo "Version: ${BSP_VERSION}" >> ${IMAGE_ROOTFS}/etc/issue
}

ROOTFS_POSTPROCESS_COMMAND_remove = "update_issue; "
ROOTFS_POSTPROCESS_COMMAND_append = " rz_update_issues; "
