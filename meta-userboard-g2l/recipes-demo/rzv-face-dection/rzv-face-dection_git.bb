FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

LIC_FILES_CHKSUM = "file://${WORKDIR}/git/LICENSE;md5=d560fe88289c88f1d4ad2a876ed37608"
LICENSE = "MIT"

SRCREV = "f85f325f05fd7116a312f212694ef4de7bd599bb"
SRC_URI = " \
	git://github.com/Ignitarium-Renesas/RZV2L_AiLibrary.git;protocol=https;branch=main \
	file://Elderly_fall_detection \
	file://Face_recognition_img \
	file://Face_spoof_detection_cam \
	file://Head_count_img \
	file://res \
	file://Safety_helmet_vest_img \
	file://database \
	file://Face_recognition_cam \
	file://Face_registration \
	file://Face_spoof_detection_img \
	file://Head_count_cam \
	file://Line_crossing_object_counting \
	file://Safety_helmet_vest_cam \
"

inherit pkgconfig

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
	install -d ${D}/home/root/Face-dection

	cp -Rfv ${WORKDIR}/Head_count_cam ${D}/home/root || true
	install ${S}/01_Head_count/Head_count_cam/exe/head_count_cam_app ${D}/home/root/Head_count_cam/exe/Head_count_cam || true

	cp -Rfv ${WORKDIR}/Head_count_img ${D}/home/root || true
	install ${S}/01_Head_count/Head_count_img/exe/01_head_count_img_app ${D}/home/root/Head_count_img/exe/Head_count_img || true

	cp -Rfv ${WORKDIR}/Line_crossing_object_counting ${D}/home/root || true
	install ${S}/02_Line_crossing_object_counting/exe/02_Line_crossing_object_counting ${D}/home/root/Line_crossing_object_counting/exe/Line_crossing_object_counting || true

	cp -Rfv ${WORKDIR}/Elderly_fall_detection ${D}/home/root || true
	install ${S}/03_Elderly_fall_detection/exe/03_Elderly_fall_detection ${D}/home/root/Elderly_fall_detection/exe/Elderly_fall_detection || true

	cp -Rfv ${WORKDIR}/Safety_helmet_vest_cam ${D}/home/root || true
	install ${S}/04_Safety_Helmet_Vest_Detection/Safety_helmet_vest_cam/exe/04_Safety_helmet_vest_cam_app ${D}/home/root/Safety_helmet_vest_cam/exe/Safety_helmet_vest_cam || true
	cp -Rfv ${WORKDIR}/Safety_helmet_vest_img ${D}/home/root || true
	install ${S}/04_Safety_Helmet_Vest_Detection/Safety_helmet_vest_img/exe/04_Safety_helmet_vest_img_app ${D}/home/root/Safety_helmet_vest_img/exe/Safety_helmet_vest_img || true

	cp -Rfv ${WORKDIR}/Face_recognition_cam ${D}/home/root/Face-dection || true
	install ${S}/06_Face_recognition_spoof_detection/Face_recognition_cam/exe/Face_recognition_cam ${D}/home/root/Face-dection/Face_recognition_cam/exe/ || true
	cp -Rfv ${WORKDIR}/Face_recognition_img ${D}/home/root/Face-dection || true
	install ${S}/06_Face_recognition_spoof_detection/Face_recognition_img/exe/Face_recognition_img ${D}/home/root/Face-dection/Face_recognition_img/exe/ || true
	cp -Rfv ${WORKDIR}/Face_spoof_detection_cam ${D}/home/root/Face-dection || true
	install ${S}/06_Face_recognition_spoof_detection/Face_spoof_detection_cam/exe/Face_spoof_detection_cam ${D}/home/root/Face-dection/Face_spoof_detection_cam/exe/ || true
	cp -Rfv ${WORKDIR}/Face_spoof_detection_img ${D}/home/root/Face-dection || true
	install ${S}/06_Face_recognition_spoof_detection/Face_spoof_detection_img/exe/Face_spoof_detection_img ${D}/home/root/Face-dection/Face_spoof_detection_img/exe/ || true
	cp -Rfv ${WORKDIR}/Face_registration ${D}/home/root/Face-dection || true
	install ${S}/06_Face_recognition_spoof_detection/Face_registration/exe/Face_registration ${D}/home/root/Face-dection/Face_registration/exe/ || true
	cp -Rfv ${WORKDIR}/res ${D}/home/root/Face-dection || true
	cp -Rfv ${WORKDIR}/database ${D}/home/root/Face-dection || true
}

FILES_${PN} = " \
	/home/root/Line_crossing_object_counting \
	/home/root/Head_count_cam \
	/home/root/Head_count_img \
	/home/root/Elderly_fall_detection \
	/home/root/Safety_helmet_vest_cam \
	/home/root/Safety_helmet_vest_img \
	/home/root/Face-dection \
"

INSANE_SKIP_${PN} += " file-rdeps installed-vs-shipped "
INSANE_SKIP_${PN}-dev += " file-rdeps iinstalled-vs-shipped "

