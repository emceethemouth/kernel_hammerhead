#!/bin/bash
#
#  TheArkenstone
#

rm arch/arm/boot/zImage-dtb
rm boot.img
rm kernel.log
rm zip/boot.img
rm zip/TheArkenstone-HH-L.zip

clear

echo ""
echo ""
echo "Start kernel build"
echo ""
echo ""

git checkout android-L

make clean
make mrproper
export ARCH=arm
export CROSS_COMPILE=~/tmp/arm-eabi-4.10/bin/arm-eabi-
export ENABLE_GRAPHITE=true
make hammerhead_defconfig
time make -j4 2>&1 | tee kernel.log

echo ""
echo "Building boot.img"
cp arch/arm/boot/zImage-dtb ../ramdisk_L/

cd ../ramdisk_L/

echo ""
echo "building ramdisk"
./mkbootfs ramdisk | gzip > ramdisk.gz
echo ""
echo "making boot image"
./mkbootimg --base 0x00000000 --ramdisk_offset 0x02900000 --second_offset 0x00F00000 --tags_offset 0x02700000 --cmdline 'console=ttyHSL0 androidboot.hardware=hammerhead user_debug=31 maxcpus=2 msm_watchdog_v2.enable=1 earlyprintk' --kernel zImage-dtb --ramdisk ramdisk.gz --output ../hammerhead_L/boot.img

rm -rf ramdisk.gz
rm -rf zImage

cd ../hammerhead_L/

zipfile="TheArkenstone-HH-L.zip"
echo ""
echo "zipping kernel"
cp boot.img zip/

rm -rf ../ramdisk_L/boot.img

cd zip/
rm -f *.zip
zip -r -9 $zipfile *
rm -f /tmp/*.zip
cp *.zip /tmp

cd ..
rm arch/arm/boot/zImage-dtb
rm boot.img
rm kernel.log
rm zip/boot.img

echo ""
echo ""
echo "Kernel build done"
echo ""
echo ""
