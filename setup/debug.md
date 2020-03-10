# Debug Kernel with GDB

This document describes how to use GDB to debug QEMU emulated linux kernel.

## Compile Kernel with Debug Info
```
cd linux
make ARCH=arm menuconfig
```

Load existing .config and update it as following:

* Symbol: DEBUG_INFO [=y]
* Symbol: GDB_SCRIPTS [=y]
* Symbol: KERNEL_MODE_NEON [=n]

```
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j $(getconf _NPROCESSORS_ONLN) zImage modules dtbs
```

## Emulating Kernel with Debug Option
```
qemu-system-arm -M raspi2 -kernel linux/arch/arm/boot/zImage \
-dtb linux/arch/arm/boot/dts/bcm2709-rpi-2-b.dtb \
-append "rw earlyprintk loglevel=10 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2" \
-serial stdio -sd 2017-01-11-raspbian-jessie-lite.img -S -s
```

## Attach GDB to Emulated Kernel
- Install GDB multiarch
```
sudo apt-get install gdb-multiarch
```

- Create GDB command file `gdbcmd` with following content:
```
set architecture arm
add-auto-load-safe-path ./linux/scripts/gdb/vmlinux-gdb.py
file linux/vmlinux
target remote :1234
b bcm2835_mmc_probe
command
bt
c
end
c
```

- Run GDB
```
gdb-multiarch -x gdbcmd
```
Finally, you will get the callstack of bcm2835_mmc_probe as specified in `gdbcmd`.

>```
Breakpoint 1, bcm2835_mmc_probe (pdev=0xba9dec00) at drivers/mmc/host/bcm2835-mmc.c:1404
#0  bcm2835_mmc_probe (pdev=0xba9dec00) at drivers/mmc/host/bcm2835-mmc.c:1404
#1  0x8039ebd4 in platform_drv_probe (_dev=0xba9dec10) at drivers/base/platform.c:518
#2  0x8039d0b8 in really_probe (drv=<optimized out>, dev=<optimized out>) at drivers/base/dd.c:316
#3  driver_probe_device (drv=0xba9dec00, dev=0xba9dec10) at drivers/base/dd.c:429
#4  0x8039d220 in __driver_attach (dev=0xba9dec10, data=0x808a4ab8 <bcm2835_mmc_driver+20>) at drivers/base/dd.c:642
#5  0x8039b260 in bus_for_each_dev (bus=<optimized out>, start=<optimized out>, data=0x73, fn=0xba89e85c) at drivers/base/bus.c:314
#6  0x8039cae0 in driver_attach (drv=<optimized out>) at drivers/base/dd.c:661
#7  0x8039c6f0 in bus_add_driver (drv=0x808a4ab8 <bcm2835_mmc_driver+20>) at drivers/base/bus.c:708
#8  0x8039d8e0 in driver_register (drv=0x808a4ab8 <bcm2835_mmc_driver+20>) at drivers/base/driver.c:168
#9  0x8039ead8 in __platform_driver_register (drv=<optimized out>, owner=<optimized out>) at drivers/base/platform.c:577
#10 0x8080bb94 in bcm2835_mmc_driver_init () at drivers/mmc/host/bcm2835-mmc.c:1564
#11 0x80009754 in do_one_initcall (fn=0x8080bb7c <bcm2835_mmc_driver_init>) at init/main.c:794
#12 0x807d7f3c in do_initcall_level (level=<optimized out>) at init/main.c:859
#13 do_initcalls () at init/main.c:867
#14 do_basic_setup () at init/main.c:885
#15 kernel_init_freeable () at init/main.c:1008
#16 0x805a2e98 in kernel_init (unused=<optimized out>) at init/main.c:936
#17 0x8000f888 in ret_from_fork () at arch/arm/kernel/entry-common.S:118
```
