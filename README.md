# Kernel Hacking

This project uses QEMU to emulate Raspberry Pi 2 on Ubuntu 14.04 and hacking the corresponding linux kernel.

# Setup Environment
## 1. Prerequisite
    Working Directory : $HOME/work/hacking

## 2. QEMU
QEMU 2.8.0 is required to support Raspberry Pi 2.
```
wget http://download.qemu-project.org/qemu-2.8.0.tar.xz
tar xvJf qemu-2.8.0.tar.xz
cd qemu-2.8.0
apt-get install libgtk-3-dev
./configure --target-list=arm-softmmu
make
echo 'PATH="$PATH:$HOME/work/hacking/qemu-2.8.0/arm-softmmu"' >> $HOME/.bashrc
echo 'export PATH' >> $HOME/.bashrc
source $HOME/.bashrc
```
PS: make sure GTK support is opened before running `make`. You can check it by filter the result of configure.
```
./configure | grep GTK
GTK support       yes (3.10.8)
```

## 3. Kernel Building
```
git clone https://github.com/raspberrypi/tools
echo 'PATH="$PATH:$HOME/work/hacking/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin"' >> $HOME/.bashrc
echo 'export PATH' >> $HOME/.bashrc
source $HOME/.bashrc

git clone https://github.com/raspberrypi/linux
cd linux
git checkout rpi-4.4.y
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- bcm2709_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage modules dtbs
```
PS: in case of 64 bit OS, use following command instead:
```
echo 'PATH="$PATH:$HOME/work/hacking/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64/bin"' >> $HOME/.bashrc
```

## 4. Raspbian
Download Raspbian Jessie lite from [here](https://www.raspberrypi.org/downloads/raspbian/).
```
wget https://downloads.raspberrypi.org/raspbian_lite_latest
unzip raspbian_lite_latest
```

## 5. Emulating Raspi2
```
qemu-system-arm -M raspi2 -kernel linux/arch/arm/boot/zImage -dtb linux/arch/arm/boot/dts/bcm2709-rpi-2-b.dtb \
-append "rw earlyprintk loglevel=10 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2" \
-serial stdio -sd 2017-01-11-raspbian-jessie-lite.img
```

## 6. Login in
User : pi
Password : raspberry

## 7. Known Issue

### Patches for Known Issues.
Get patches from [here](https://github.com/craftsfish/kernelhacking/tree/master/patch) and applying them with following command.
```
git am *.patch
```

###Issue List:

- Hardware RNG Probe Issue
```
[   27.442391] INFO: rcu_sched detected stalls on CPUs/tasks:
[   27.444260] 	1-O..: (11 GPs behind) idle=001/140000000000000/0 softirq=0/0 fqs=1 
[   27.445343] 	2-O..: (11 GPs behind) idle=001/140000000000000/0 softirq=0/0 fqs=1 
[   27.446257] 	3-O..: (11 GPs behind) idle=001/140000000000000/0 softirq=0/0 fqs=1 
[   27.447190] 	(detected by 0, t=2102 jiffies, g=-289, c=-290, q=1)
[   27.448601] Task dump for CPU 1:
[   27.449334] swapper/1       R running      0     0      1 0x00000000
[   27.451899] Task dump for CPU 2:
[   27.452356] swapper/2       R running      0     0      1 0x00000000
[   27.453244] Task dump for CPU 3:
[   27.453684] swapper/3       R running      0     0      1 0x00000000
[   27.454986] rcu_sched kthread starved for 2101 jiffies! g4294967007 c4294967006 f0x0 s3 ->state=0x0
```

- Root Device Unrecognize Issue
```
[    7.247893] VFS: Cannot open root device "mmcblk0p2" or unknown-block(0,0): error -6
[    7.248815] Please append a correct "root=" boot option; here are the available partitions:
[    7.251086] 0100            4096 ram0  (driver?)
[    7.251924] 0101            4096 ram1  (driver?)
[    7.252576] 0102            4096 ram2  (driver?)
[    7.253208] 0103            4096 ram3  (driver?)
[    7.253838] 0104            4096 ram4  (driver?)
[    7.254464] 0105            4096 ram5  (driver?)
[    7.255090] 0106            4096 ram6  (driver?)
[    7.255724] 0107            4096 ram7  (driver?)
[    7.256352] 0108            4096 ram8  (driver?)
[    7.256999] 0109            4096 ram9  (driver?)
[    7.257626] 010a            4096 ram10  (driver?)
[    7.258260] 010b            4096 ram11  (driver?)
[    7.258888] 010c            4096 ram12  (driver?)
[    7.259998] 010d            4096 ram13  (driver?)
[    7.260665] 010e            4096 ram14  (driver?)
[    7.261299] 010f            4096 ram15  (driver?)
[    7.262324] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
[    7.263910] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.4.48-v7+ #2
[    7.264648] Hardware name: BCM2709
[    7.267515] [<800183c4>] (unwind_backtrace) from [<80013d3c>] (show_stack+0x20/0x24)
[    7.268571] [<80013d3c>] (show_stack) from [<80316280>] (dump_stack+0xc8/0x114)
[    7.269666] [<80316280>] (dump_stack) from [<800f7e74>] (panic+0xa4/0x20c)
[    7.270847] [<800f7e74>] (panic) from [<807d83b4>] (mount_block_root+0x1a8/0x260)
[    7.272016] [<807d83b4>] (mount_block_root) from [<807d8658>] (mount_root+0x100/0x128)
[    7.273109] [<807d8658>] (mount_root) from [<807d87e8>] (prepare_namespace+0x168/0x1c8)
[    7.274203] [<807d87e8>] (prepare_namespace) from [<807d7fb8>] (kernel_init_freeable+0x278/0x2cc)
[    7.275396] [<807d7fb8>] (kernel_init_freeable) from [<805a2f78>] (kernel_init+0x18/0xfc)
[    7.276534] [<805a2f78>] (kernel_init) from [<8000f968>] (ret_from_fork+0x14/0x2c)
[    7.279193] ---[ end Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
```

# References
- [QEMU install guide](http://www.qemu-project.org/download/#source).
- [Kernel building of Raspberry Pi](https://www.raspberrypi.org/documentation/linux/kernel/building.md).
