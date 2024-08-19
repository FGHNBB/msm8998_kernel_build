#!/bin/bash
WORKSPACE=$(pwd)
RESULT=$(pwd)/out
SOURCE=$(pwd)/src

Prepare(){
	set -eu
	if command -v sudo; then
	    sudo apt update
	else
	    apt update
	    apt install -y sudo
	fi

	sudo apt install -y \
        libssl-dev \
        python2 \
        libc6-dev \
        binutils \
        libgcc-11-dev \
        zip

	git clone --depth 1 -b lineage-21 https://github.com/FGHNBB/android_kernel_oneplus_msm8998.git
	mv android_kernel_oneplus_msm8998 src
	git clone --depth 1 https://github.com/kdrag0n/proton-clang.git
	mv proton-clang toolchains
}

Compile(){
	export PATH=$PATH:$WORKSPACE/toolchains/bin
	export CROSS_COMPILE=aarch64-linux-gnu-
	export CROSS_COMPILE_ARM32=arm-linux-gnueabi-
	export ARCH=arm64
	export CC=clang
	
	#rm -f $SOURCE/out/arch/arm64/boot/Image.gz-dtb
	
	cd $SOURCE
	make mrproper
	make ARCH=arm64 CC=clang O=out lineage_oneplus5_defconfig
	make ARCH=arm64 O=out CC=clang -j$(nproc --all)
}

Backup_Last_Result(){
	cp $RESULT/kernel_dtb.zip $RESULT/last/.
	rm $RESULT/kernel_dtb.zip
}

Compile_Time_Count(){
	starttime=`date +'%Y-%m-%d %H:%M:%S'`
	Compile
	endtime=`date +'%Y-%m-%d %H:%M:%S'`
	start_seconds=$(date --date=" $starttime" +%s);
	end_seconds=$(date --date="$endtime" +%s);
	echo Start: $starttime.
	echo End: $endtime.
	echo "Build Time: "$((end_seconds-start_seconds))"s."
}

Anykernel_Package(){
	cp $SOURCE/out/arch/arm64/boot/Image.gz-dtb $RESULT/resources/.
	cp $RESULT/resources/kernel_dtb_original.zip $RESULT/kernel_dtb.zip
	zip -u -j $RESULT/kernel_dtb.zip $RESULT/resources/Image.gz-dtb
}

Prepare
#Backup_Last_Result
Compile_Time_Count
Anykernel_Package

exit 0
