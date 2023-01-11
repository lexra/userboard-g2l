### RZ/V2L Quick Start Guide for DRP-AI and for Multi-OS package

RZ/V2L contains a proprietary AI accelerator which we called `DRPAI` and additionally is capable of multi-OS running at the same time, thus allows the given OS communication with each other accordingly.  

#### 1. Placeholder 'Renesas_software'

Place the CM33 Multi OS package, the DRPAI support package and the DRPAI translator package into this placeholder. 

```bash
 + build.sh
 |
 + sources -----------+-- meta-gplv2
 |                    |
 |                    +-- meta-openembedded
 |                    |
 |                    +-- meta-qt5
 |                    |
 |                    +-- meta-renesas
 |                    |
 |                    +-- meta-rz-features
 |                    |
 |                    +-- meta-virtualization
 |                    |
 |                    +-- poky
 |
 + meta-userboard-g2l 
 |
 + Renesas_software --+-- RTK0EF0045Z0024AZJ-v3.0.0-update2.zip
                      |
                      +-- RTK0EF0045Z13001ZJ-v1.2_EN.zip
                      |
                      +-- RTK0EF0045Z15001ZJ-v0.58_EN.zip
                      |
                      +-- r01an6238ej0102-rzv2l-cm33-multi-os-pkg.zip
                      |
                      +-- r11an0549ej0720-rzv2l-drpai-sp.zip
                      |
                      +-- r20ut5035ej0180-drp-ai-translator.zip
```

### 2. RZ/V2L Cortex-M33 Multi OS package

![image](https://user-images.githubusercontent.com/33512027/211717414-10c60ae3-1d53-4aa1-b412-812adaa96c30.png)

#### 2.1 Enter the sources directory

```bash
cd ${PROJECT_DIR}
mkdir -p sources && cd sources
```

#### 2.2 Unzip the CM33 Multi OS package

```bash
unzip -o ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg.zip -d ../Renesas_software
```

##### 2.2.1 Unzip the `rzv2l_cm33_rpmsg_demo.zip`

```bash
unzip -o ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg/rzv2l_cm33_rpmsg_demo.zip \
      -d ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg
```

##### 2.2.2 Unzip the `meta-rz-features.tar.gz` into the `sources` directory

```bash
tar zxvf ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg/meta-rz-features.tar.gz
```

#### 2.3 Bitbake core-image-qt

Run `bitbake core-image-qt` shall install the CM33 Multi OS package properly. 

```bash
bitbake core-image-qt
```

To uninstall, 

```bash
rm -rfv meta-rz-features/recipes-openamp
```

### 3. RZ/V2L `DRPAI` support package

![image](https://user-images.githubusercontent.com/33512027/211717812-11ddd876-0e96-427a-a600-771dbe3affb7.png)

#### 3.1 Unzip the `DRPAI` support package

```bash
cd ${PROJECT_DIR}
mkdir -p sources && cd sources
```

```bash
unzip -o ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp.zip -d ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp
```

##### 3.1.1 Unzip the `meta-rz-features.tar.gz` into the `sources` directory

```bash
tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-driver/meta-rz-features.tar.gz
```

This step is identical to `2.2.2`, just the content of each `meta-rz-features.tar.gz` is different. 

##### 3.1.2 Unzip the `DRPAI` sample application

```bash
tar zxvf \
  ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/rzv2l_drpai-sample-application_ver7.20.tar.gz \
  -C ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application
```

##### 3.1.3 Unzip the `DRPAI` implementation guide

```bash
tar zxvf \
  ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide/rzv_ai-implementation-guide_ver7.20.tar.gz \
  -C ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide
```

##### 3.1.4 Copy prebuilt sample applications

```bash
cp -Rpfv ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/app_resnet50_cam \
         ../meta-userboard-g2l/recipes-demo/app-resnet50-cam
cp -Rpfv ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/app_resnet50_img \
         ../meta-userboard-g2l/recipes-demo/app-resnet50-img
cp -Rpfv ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/app_tinyyolov2_cam \
         ../meta-userboard-g2l/recipes-demo/app-tinyyolov2-cam
cp -Rpfv ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-sample-application/app_yolo_img \
         ../meta-userboard-g2l/recipes-demo/app-yolo-img
```

#### 3.2 Edit the `meta-rz-features/conf/layer.conf`

The steps described might modify the content of `meta-rz-features/conf/layer.conf` ; please use the following to correct the `meta-rz-features/conf/layer.conf` .  

```bash
# We have a conf and classes directory, add to BBPATH

include ${LAYERDIR}/include/graphic/feature.inc
include ${LAYERDIR}/include/codec/plugin.inc
include ${LAYERDIR}/include/demos/demos.inc
include ${LAYERDIR}/include/drpai/core-image-sdk.inc
include ${LAYERDIR}/include/drpai/extend_packages.inc
include ${LAYERDIR}/include/openamp/openamp.inc

LAYERDEPENDS_rz-features = "rzg2"

BBPATH .= ":${LAYERDIR}"

BBFILE_COLLECTIONS += "rz-features"
BBFILE_PATTERN_rz-features := "^${LAYERDIR}/"

# We have recipes-* directories, add to BBFILES
BBFILES += "${LAYERDIR}/recipes-*/*/*.bb \
    ${LAYERDIR}/recipes-*/*.bb \
    ${LAYERDIR}/recipes-*/*.bbappend \
    ${LAYERDIR}/recipes-*/*/*.bbappend"

# Add DRP-AI Support PKG
DRPAI_RECIPES = "${@os.path.isdir("${LAYERDIR}/recipes-drpai")}"

BBFILES_append += "${@'${LAYERDIR}/recipes-drpai/*/*/*.bb' if '${DRPAI_RECIPES}' == 'True' else ''} \
                   ${@'${LAYERDIR}/recipes-drpai/*/*/*/*.bb' if '${DRPAI_RECIPES}' == 'True' else ''} \
                   ${@'${LAYERDIR}/recipes-drpai/*/*/*.bbappend' if '${DRPAI_RECIPES}' == 'True' else ''} \
                   ${@'${LAYERDIR}/recipes-drpai/*/*/*/*.bbappend' if '${DRPAI_RECIPES}' == 'True' else ''} "

# Add ISP Support PKG
ISP_RECIPES = "${@os.path.isdir("${LAYERDIR}/recipes-isp")}"

BBFILES_append += "${@'${LAYERDIR}/recipes-isp/*/*/*.bb' if '${ISP_RECIPES}' == 'True' else ''} \
                   ${@'${LAYERDIR}/recipes-isp/*/*/*/*.bb' if '${ISP_RECIPES}' == 'True' else ''} \
                   ${@'${LAYERDIR}/recipes-isp/*/*/*.bbappend' if '${ISP_RECIPES}' == 'True' else ''} \
                   ${@'${LAYERDIR}/recipes-isp/*/*/*/*.bbappend' if '${ISP_RECIPES}' == 'True' else ''} "
```

#### 3.3 Bitbake core-image-qt

Run `bitbake core-image-qt` shall properly rebuild and install the RZ/V2L DRPAI sample applications. 

```bash
bitbake core-image-qt
```

To uninstall, 

```bash
rm -rfv meta-rz-features/recipes-drpai
rm -rfv meta-rz-features/include/drpai
```

### 4. `DRPAI` Translate

We take the `app-resnet50-cam` for an example to demostrate steps of DRPAI-Translate. 

#### 4.1  Inatall the `DRPAI` translator

```bash
unzip -o ../Renesas_software/r20ut5035ej0180-drp-ai-translator.zip -d ../Renesas_software/drp-ai-translator
chmod +x ../Renesas_software/drp-ai-translator/DRP-AI_Translator-v1.80-Linux-x86_64-Install
cd ..
echo y | Renesas_software/drp-ai-translator/DRP-AI_Translator-v1.80-Linux-x86_64-Install
cd -
```

#### 4.2  Extract the `pytorch_resnet_ver7.20.tar.gz` to `drp-ai_translator_release`

```
tar zxvf \
 ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide/pytorch_resnet/pytorch_resnet_ver7.20.tar.gz \
 -C ../drp-ai_translator_release

tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide/mmpose_hrnet/mmpose_hrnet_ver7.20.tar.gz \
      -C ../drp-ai_translator_release

tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide/darknet_yolo/darknet_yolo_ver7.20.tar.gz \
      -C ../drp-ai_translator_release

tar zxvf \
../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv_ai-implementation-guide/pytorch_mobilenet/pytorch_mobilenet_ver7.20.tar.gz \
-C ../drp-ai_translator_release
```

#### 4.3  DRPAI translate

##### 4.3.1  Environment export

```bash
export DRPAI_TRANSLATOR_RELEASE=../../../drp-ai_translator_release
export APP_NAME=app_resnet50_cam
export APP_RECIPE=$(echo $APP_NAME | sed 's/_/-/g')
export MODEL=resnet50
export IMG_SRC=cam
```

##### 4.3.2  Change directory to `meta-userboard-g2l/recipes-demo/app-resnet50-cam`

```bash
cd ${PROJECT_DIR}
cd meta-userboard-g2l/recipes-demo/app-resnet50-cam
```

##### 4.3.3  Generate a new `resnet50.onnx`

```bash
cd ${DRPAI_TRANSLATOR_RELEASE}/pytorch/${MODEL}
python3 convert_to_onnx.py
cp -Rpfv ./${MODEL}.onnx ../../onnx
cd -
```

##### 4.3.4  DRPAI translate for `app_resnet50_cam`

```bash
cd ${DRPAI_TRANSLATOR_RELEASE}
rm -rf output/${MODEL}_${IMG_SRC}
./run_DRP-AI_translator_V2L.sh ${MODEL}_${IMG_SRC} \
	-onnx onnx/${MODEL}.onnx \
	-prepost ../meta-userboard-g2l/recipes-demo/${APP_RECIPE}/${APP_NAME}/etc/prepost_${MODEL}.yaml \
	-addr ../meta-userboard-g2l/recipes-demo/${APP_RECIPE}/${APP_NAME}/etc/addrmap_in_${MODEL}.yaml
cd -
```

![image](https://user-images.githubusercontent.com/33512027/211740259-e999dcfc-65d7-4991-8b95-3a9999bdc099.png)


##### 4.3.5  Copy output data to `app_resnet50_cam/exe`

```bash
cp -Rpf ${DRPAI_TRANSLATOR_RELEASE}/output/${MODEL}_${IMG_SRC} ${APP_NAME}/exe
```

##### 4.3.6 Bitbake core-image-qt

Run `bitbake core-image-qt` shall properly rebuild and install the newly generated `app_resnet50_cam`. 

```bash
bitbake core-image-qt
```


