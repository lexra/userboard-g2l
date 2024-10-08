FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=d560fe88289c88f1d4ad2a876ed37608"
LICENSE = "MIT"

SVC = "headcount-cam"
SRCREV = "f85f325f05fd7116a312f212694ef4de7bd599bb"
SRC_URI = " \
	git://github.com/Ignitarium-Renesas/RZV2L_AiLibrary.git;protocol=https;branch=main \
	file://${SVC}.sh \
	file://${SVC}.service \
"

SYSTEMD_SERVICE_${SVC}= "${SVC}.service"
SYSTEMD_AUTO_ENABLE = "disable"

inherit pkgconfig systemd

DEPENDS += " \
        drpai \
        opencv \
	wayland wayland-protocols \
	libjpeg-turbo openjpeg \
	libpng \
	glib-2.0 \
	cairo \
	pango \
	gdk-pixbuf \
	libwebp \
	tiff \
	gtk+3 \
	libzip \
	libepoxy \
	freetype \
	harfbuzz \
	fontconfig \
	expat \
	pixman \
"

S = "${WORKDIR}/git"

do_compile () {
	APP_NAME=Head_count_cam && MODEL=yolov3 && IMG_SRC=cam
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/01_Head_count/${APP_NAME} clean all
	APP_NAME=Head_count_img && MODEL=yolov3 && IMG_SRC=bmp
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/01_Head_count/${APP_NAME} clean all

	APP_NAME=Line_crossing_object_counting && MODEL=tinyyolov2 && IMG_SRC=cam
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/02_${APP_NAME} clean all

	APP_NAME=Elderly_fall_detection && MODEL=tinyyolov2 && IMG_SRC=cam
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/03_${APP_NAME} clean all

	APP_NAME=Safety_helmet_vest_cam && MODEL=yolov3 && IMG_SRC=cam
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/04_Safety_Helmet_Vest_Detection/${APP_NAME} clean all
	APP_NAME=Safety_helmet_vest_img && MODEL=yolov3 && IMG_SRC=img
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/04_Safety_Helmet_Vest_Detection/${APP_NAME} clean all

	APP_NAME=Age_classifier_img && MODEL=resnet18 && IMG_SRC=bmp
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/05_Age_Gender_Detection/05_${APP_NAME} clean all
	APP_NAME=Gender_classifier_img && MODEL=pytorch && IMG_SRC=bmp
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/05_Age_Gender_Detection/05_${APP_NAME} clean all

	APP_NAME=Face_recognition_cam && MODEL=resnet50 && IMG_SRC=cam
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/06_Face_recognition_spoof_detection/${APP_NAME} clean all

	APP_NAME=Face_recognition_img && MODEL=resnet50 && IMG_SRC=bmp
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/06_Face_recognition_spoof_detection/${APP_NAME} clean all

	APP_NAME=Face_spoof_detection_cam && MODEL=resnet50 && IMG_SRC=classifier_cam
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/06_Face_recognition_spoof_detection/${APP_NAME} clean all

	APP_NAME=Face_spoof_detection_img && MODEL=resnet50 && IMG_SRC=classifier_bmp
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/06_Face_recognition_spoof_detection/${APP_NAME} clean all

	APP_NAME=Face_registration && MODEL=resnet50 && IMG_SRC=bmp
	oe_runmake SDKTARGETSYSROOT=${STAGING_DIR_TARGET} -C ${S}/06_Face_recognition_spoof_detection/${APP_NAME} clean all
}

do_install_class-target () {
	install -d ${D}/home/root/Head_count
	install ${WORKDIR}/${SVC}.sh ${D}/home/root/Head_count
	install -d ${D}${nonarch_base_libdir}/systemd/system
	install ${WORKDIR}/${SVC}.service ${D}${nonarch_base_libdir}/systemd/system

	install -d ${D}/home/root/Head_count/yolov3_cam
	install -m 755 ${S}/01_Head_count/Head_count_cam/exe/head_count_cam_app ${D}/home/root/Head_count/Head_count_cam
	install ${S}/01_Head_count/Head_count_cam/exe/yolov3_cam/* ${D}/home/root/Head_count/yolov3_cam
	wget https://github.com/Ignitarium-Renesas/RZV2L_AiLibrary/releases/download/v1.2.1/yolov3_cam_weight.dat -O ${D}/home/root/Head_count/yolov3_cam/yolov3_cam_weight.dat

	install -d ${D}/home/root/Head_count/yolov3_bmp
	install -m 755 ${S}/01_Head_count/Head_count_img/exe/01_head_count_img_app ${D}/home/root/Head_count/Head_count_img
	install -m 644 ${S}/01_Head_count/Head_count_img/exe/labels.txt ${D}/home/root/Head_count
	install ${S}/01_Head_count/Head_count_img/exe/yolov3_bmp/* ${D}/home/root/Head_count/yolov3_bmp
	wget https://github.com/Ignitarium-Renesas/RZV2L_AiLibrary/releases/download/v1.2.1/yolov3_bmp_weight.dat -O ${D}/home/root/Head_count/yolov3_bmp/yolov3_bmp_weight.dat
	install -d ${D}/home/root/Head_count/test_images
	install ${S}/01_Head_count/Head_count_img/test_images/* ${D}/home/root/Head_count/test_images

	#install -d ${D}/home/root/Line_crossing_object_counting/exe/tinyyolov2_cam
	#install ${S}/02_Line_crossing_object_counting/exe/02_Line_crossing_object_counting ${D}/home/root/Line_crossing_object_counting/exe/Line_crossing_object_counting
	#install ${S}/02_Line_crossing_object_counting/exe/tinyyolov2_cam/* ${D}/home/root/Line_crossing_object_counting/exe/tinyyolov2_cam
	#install ${S}/02_Line_crossing_object_counting/sample_office.png ${D}/home/root/Line_crossing_object_counting
	#install ${S}/02_Line_crossing_object_counting/tracker_ss.png ${D}/home/root/Line_crossing_object_counting

	#install -d ${D}/home/root/Elderly_fall_detection/exe/hrnet_cam
	#install -d ${D}/home/root/Elderly_fall_detection/exe/tinyyolov2_cam
	#install ${S}/03_Elderly_fall_detection/exe/03_Elderly_fall_detection ${D}/home/root/Elderly_fall_detection/exe/Elderly_fall_detection
	#install ${S}/03_Elderly_fall_detection/exe/hrnet_cam/* ${D}/home/root/Elderly_fall_detection/exe/hrnet_cam
	#install ${S}/03_Elderly_fall_detection/exe/tinyyolov2_cam/* ${D}/home/root/Elderly_fall_detection/exe/tinyyolov2_cam

	#install -d ${D}/home/root/Safety_helmet_vest_cam/exe/yolov3
	#install ${S}/04_Safety_Helmet_Vest_Detection/Safety_helmet_vest_cam/exe/04_Safety_helmet_vest_cam_app ${D}/home/root/Safety_helmet_vest_cam/exe/Safety_helmet_vest_cam
	#install ${S}/04_Safety_Helmet_Vest_Detection/Safety_helmet_vest_cam/exe/yolov3/* ${D}/home/root/Safety_helmet_vest_cam/exe/yolov3

	#install -d ${D}/home/root/Safety_helmet_vest_img/exe/yolov3
	#install ${S}/04_Safety_Helmet_Vest_Detection/Safety_helmet_vest_img/exe/04_Safety_helmet_vest_img_app ${D}/home/root/Safety_helmet_vest_img/exe/Safety_helmet_vest_img
	#install ${S}/04_Safety_Helmet_Vest_Detection/Safety_helmet_vest_img/exe/yolov3/* ${D}/home/root/Safety_helmet_vest_img/exe/yolov3
	#install ${S}/04_Safety_Helmet_Vest_Detection/Safety_helmet_vest_img/exe/labels.txt ${D}/home/root/Safety_helmet_vest_img/exe
	#install -d ${D}/home/root/Safety_helmet_vest_img/test_images
	#install ${S}/04_Safety_Helmet_Vest_Detection/Safety_helmet_vest_img/test_images/* ${D}/home/root/Safety_helmet_vest_img/test_images

	#install -d ${D}/home/root/Face-dection/res
	#install ${S}/06_Face_recognition_spoof_detection/res/* ${D}/home/root/Face-dection/res
	#install -d ${D}/home/root/Face-dection/database
	#install ${S}/06_Face_recognition_spoof_detection/database/* ${D}/home/root/Face-dection/database
	#install -d ${D}/home/root/Face-dection/Face_recognition_cam/exe/resnet50_cam
	#install ${S}/06_Face_recognition_spoof_detection/Face_recognition_cam/exe/Face_recognition_cam ${D}/home/root/Face-dection/Face_recognition_cam/exe
	#install ${S}/06_Face_recognition_spoof_detection/Face_recognition_cam/exe/resnet50_cam/* ${D}/home/root/Face-dection/Face_recognition_cam/exe/resnet50_cam

	#install -d ${D}/home/root/Face-dection/Face_recognition_img/exe/resnet50_bmp
	#install ${S}/06_Face_recognition_spoof_detection/Face_recognition_img/exe/Face_recognition_img ${D}/home/root/Face-dection/Face_recognition_img/exe
	#install ${S}/06_Face_recognition_spoof_detection/Face_recognition_img/exe/sample.bmp ${D}/home/root/Face-dection/Face_recognition_img/exe
	#install ${S}/06_Face_recognition_spoof_detection/Face_recognition_img/exe/resnet50_bmp/* ${D}/home/root/Face-dection/Face_recognition_img/exe/resnet50_bmp

	#install -d ${D}/home/root/Face-dection/Face_spoof_detection_cam/exe/resnet50_classifier_cam
	#install ${S}/06_Face_recognition_spoof_detection/Face_spoof_detection_cam/exe/Face_spoof_detection_cam ${D}/home/root/Face-dection/Face_spoof_detection_cam/exe
	#install ${S}/06_Face_recognition_spoof_detection/Face_spoof_detection_cam/exe/resnet50_classifier_cam/* ${D}/home/root/Face-dection/Face_spoof_detection_cam/exe/resnet50_classifier_cam

	#install -d ${D}/home/root/Face-dection/Face_spoof_detection_img/exe/resnet50_classifier_bmp
	#install ${S}/06_Face_recognition_spoof_detection/Face_recognition_img/exe/sample.bmp ${D}/home/root/Face-dection/Face_spoof_detection_img/exe
	#install ${S}/06_Face_recognition_spoof_detection/Face_spoof_detection_img/exe/Face_spoof_detection_img ${D}/home/root/Face-dection/Face_spoof_detection_img/exe
	#install ${S}/06_Face_recognition_spoof_detection/Face_spoof_detection_img/exe/resnet50_classifier_bmp/* ${D}/home/root/Face-dection/Face_spoof_detection_img/exe/resnet50_classifier_bmp

	#install -d ${D}/home/root/Face-dection/Face_registration/exe/resnet50_bmp
	#install ${S}/06_Face_recognition_spoof_detection/Face_registration/exe/Face_registration ${D}/home/root/Face-dection/Face_registration/exe/
	#install ${S}/06_Face_recognition_spoof_detection/Face_registration/exe/resnet50_bmp/* ${D}/home/root/Face-dection/Face_registration/exe/resnet50_bmp
}

FILES_${PN} += " \
	${nonarch_base_libdir} \
	/home/root/Head_count \
"

#FILES_${PN} = " \
#	/home/root/Line_crossing_object_counting \
#	/home/root/Head_count_cam \
#	/home/root/Head_count_img \
#	/home/root/Elderly_fall_detection \
#	/home/root/Safety_helmet_vest_cam \
#	/home/root/Safety_helmet_vest_img \
#	/home/root/Face-dection \
#"

INSANE_SKIP_${PN} += " file-rdeps installed-vs-shipped "
INSANE_SKIP_${PN}-dev += " file-rdeps iinstalled-vs-shipped "

