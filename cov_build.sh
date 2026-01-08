#!/bin/bash
set -e
set -x
##############################
GITHUB_WORKSPACE="${PWD}"
ls -la ${GITHUB_WORKSPACE}
############################
# Build entservices-firmwaredownload
echo "======================================================================================"
echo "buliding entservices-firmwaredownload"

cd ${GITHUB_WORKSPACE}
cmake -G Ninja -S "$GITHUB_WORKSPACE" -B build/entservices-firmwaredownload \
-DUSE_THUNDER_R4=ON \
-DCMAKE_INSTALL_PREFIX="$GITHUB_WORKSPACE/install/usr" \
-DCMAKE_MODULE_PATH="$GITHUB_WORKSPACE/install/tools/cmake" \
-DCMAKE_VERBOSE_MAKEFILE=ON \
-DLIBOPKG_LIBRARIES="" \
-DLIBOPKG_INCLUDE_DIRS="" \
-DCOMCAST_CONFIG=OFF \
-DRDK_SERVICES_COVERITY=ON \
-DRDK_SERVICES_L1_TEST=ON \
-DPLUGIN_FIRMWAREDOWNLOAD=ON \
-DCMAKE_CXX_FLAGS="-DEXCEPTIONS_ENABLE=ON \
-Wall -Wno-unused-result -Wno-deprecated-declarations -Werror -Wno-error=format \
-Wl,-wrap,system -Wl,-wrap,popen -Wl,-wrap,syslog -Wl,-wrap,wpa_ctrl_open -Wl,-wrap,wpa_ctrl_request -Wl,-wrap,wpa_ctrl_close -Wl,-wrap,wpa_ctrl_pending -Wl,-wrap,wpa_ctrl_recv -Wl,-wrap,wpa_ctrl_attach \
-DDISABLE_SECURITY_TOKEN -DUSE_THUNDER_R4=ON -DTHUNDER_VERSION=4 -DTHUNDER_VERSION_MAJOR=4 -DTHUNDER_VERSION_MINOR=4"

cmake --build build/entservices-firmwaredownload --target install
echo "======================================================================================"
exit 0
