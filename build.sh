#!/bin/bash

function compile() 
{

source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST=void
export KBUILD_BUILD_USER="DemonDrake"
ZIPNAME=Void-OSS-KERNEL-RELEASE-"${DATE}".zip
git clone --depth=1 https://gitlab.com/LeCmnGend/proton-clang clang

[ -d "AnyKernel" ] && rm -rf AnyKernel
[ -d "out" ] && rm -rf out || mkdir -p out

# Built In Timer
SECONDS=0

curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -

make O=out ARCH=arm64 vendor/lahaina-qgki_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}:${PWD}/clang/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      	ARCH=arm64 \
                      	CC="clang" \
                      	CLANG_TRIPLE=aarch64-linux-gnu- \
                      	CROSS_COMPILE="${PWD}/clang/bin/aarch64-linux-gnu-" \
						CROSS_COMPILE_ARM32="${PWD}/clang/bin/arm-linux-gnueabi-" \
                      	CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log 
}

function zipping()
{
git clone --depth=1 https://github.com/cd-Seraph/AnyKernel3.git -b master AnyKernel
cp out/arch/arm64/boot/Image AnyKernel
python scripts/dtc/libfdt/mkdtboimg.py create AnyKernel/dtbo.img --page_size=4096 out/arch/arm64/boot/dts/vendor/oplus_7325/yupik-21643-overlay.dtbo
cd AnyKernel
zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
cd ..
echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
}
compile
zipping
