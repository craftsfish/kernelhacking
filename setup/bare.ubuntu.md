```
sudo apt-get install git build-essential kernel-package fakeroot libncurses5-dev libssl-dev ccache bison flex libelf-dev
git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
cd linux
cp /boot/config-`uname -r` .config
yes '' | make oldconfig #old + default for new #optionally use(yes '' | make oldconfig)
yes '' | make localmodconfig #remove unnecessary ones
make menuconfig
make clean
make -j $(getconf _NPROCESSORS_ONLN) LOCALVERSION=-custom
sudo make -j $(getconf _NPROCESSORS_ONLN) INSTALL_MOD_STRIP=1 modules_install
sudo make install

#make -j $(getconf _NPROCESSORS_ONLN) deb-pkg LOCALVERSION=-custom
#make ARCH=x86_64 -j $(getconf _NPROCESSORS_ONLN) bindeb-pkg LOCALVERSION=-custom
cd ..
sudo dpkg -i linux-image-2.6.24-rc5-custom_2.6.24-rc5-custom-10.00.Custom_i386.deb
sudo dpkg -i linux-headers-2.6.24-rc5-custom_2.6.24-rc5-custom-10.00.Custom_i386.deb
sudo reboot
```

[link](https://wiki.ubuntu.com/KernelTeam/GitKernelBuild)


make INSTALL_HDR_PATH='/tmp' headers_install
