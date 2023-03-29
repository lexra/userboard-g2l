PACKAGECONFIG[opencl] = "-DWITH_OPENCL=ON,-DWITH_OPENCL=OFF"

PACKAGECONFIG_append_pn-opencv = " opencl"
PACKAGECONFIG_append_pn-nativesdk-opencv = " opencl"
