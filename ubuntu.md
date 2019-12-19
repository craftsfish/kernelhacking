sudo apt-get install git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache bison flex

git clone git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

cd linux

cp /boot/config-`uname -r` .config

yes '' | make oldconfig

make menuconfig

make clean

make -j `getconf _NPROCESSORS_ONLN` deb-pkg LOCALVERSION=-custom

cd ..

sudo dpkg -i linux-image-2.6.24-rc5-custom_2.6.24-rc5-custom-10.00.Custom_i386.deb
sudo dpkg -i linux-headers-2.6.24-rc5-custom_2.6.24-rc5-custom-10.00.Custom_i386.deb

sudo reboot

[ref](https://wiki.ubuntu.com/KernelTeam/GitKernelBuild)
