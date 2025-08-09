#!/bin/sh

# download buildroot from https://buildroot.org/download.html and extract it, change the following accordingly
BUILDROOT=buildroot-2025.05 
# Supported targets: cmhybrid (supports cm1 cm3), cm4
TARGET=cm4

#
# Extract the tarball containing the unmodified buildroot version 
#
if [ ! -e $BUILDROOT ]; then
    tar xzf $BUILDROOT.tar.gz
fi

#
# To delete old config 
#
# make -C buildroot-2025.05/ distclean

#
# Tell buildroot we have extra files in our external directory
# and use our scriptexecute_defconfig configuration file 
#
if [ ! -e $BUILDROOT/.config ]; then
    make -C $BUILDROOT BR2_EXTERNAL="$PWD/scriptexecute" scriptexecute_${TARGET}_defconfig
fi

#
# To edit the .config in menuconfig that was saved with scriptexecute_${TARGET}_defconfig
#
make -C $BUILDROOT menuconfig

#
# To save the config to the defconfig.
#
# make -C $BUILDROOT savedefconfig

#
# Most accurate way to save it into the right defconfig is where 'scriptexecute_cm4_defconfig' is the name of new defconfig
#
# make BR2_EXTERNAL=../scriptexecute BR2_DEFCONFIG=../scriptexecute/configs/scriptexecute_cm4_defconfig savedefconfig

#
# Build everything
#
make -j$(nproc) -C $BUILDROOT

#
# Copy the files we are interested in from buildroot's "output/images" directory
# to our "output" directory in top level directory 
#

# initramfs file build by buildroot containing the root file system
cp $BUILDROOT/output/images/rootfs.cpio.xz output/scriptexecute.img
# Linux kernel
cp $BUILDROOT/output/images/zImage output/kernel.img
# Raspberry Pi firmware files
cp $BUILDROOT/output/images/rpi-firmware/*.elf output
cp $BUILDROOT/output/images/rpi-firmware/*.dat output
cp $BUILDROOT/output/images/rpi-firmware/bootcode.bin output
cp $BUILDROOT/output/images/*.dtb output

# Uncomment if using dwc2
mkdir -p output/overlays
mv output/dwc2-overlay.dtb output/overlays/dwc2.dtbo
mv output/spi-gpio40-45-overlay.dtb output/overlays/spi-gpio40-45.dtbo

echo
echo Build complete. Files are in output folder.
echo
