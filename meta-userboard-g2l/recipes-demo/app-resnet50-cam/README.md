### DRP-AI + Multi OS package

#### 1 Placeholder 'Renesas_software'

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

### 2 RZ/V2L Cortex-M33 Multi OS package

#### 2.1 Enter the sources directory

```
mkdir -p sources && cd sources
```

#### 2.2 Unzip the CM33 Multi OS package

```bash
unzip -o ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg.zip -d ../Renesas_software
```

##### 2.2.1 Unzip the rzv2l_cm33_rpmsg_demo.zip

```
unzip -o ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg/rzv2l_cm33_rpmsg_demo.zip \
      -d ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg
```

##### 2.2.2 Unzip the meta-rz-features.tar.gz into the `sources` directory

```
tar zxvf ../Renesas_software/r01an6238ej0102-rzv2l-cm33-multi-os-pkg/meta-rz-features.tar.gz
```

#### 2.3 Bitbake core-image-qt

Run `bitbake core-image-qt` shall install CM33 Multi OS package properly. 

```
bitbake core-image-qt
```

To uninstall, 

```
rm -rfv meta-rz-features/recipes-openamp
```

### 3 RZ/V2L DRP-AI support package

#### 3.1 Unzip the DRPAI support package

```
unzip -o ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp.zip -d ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp
```

##### 3.1.1 Unzip the meta-rz-features.tar.gz into the `sources` directory

```
tar zxvf ../Renesas_software/r11an0549ej0720-rzv2l-drpai-sp/rzv2l_drpai-driver/meta-rz-features.tar.gz
```

