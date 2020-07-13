# Kernel Parameters

This document describes how kernel parameters are parsed.

## Registration
```
early_param
__setup_param
__setup
```

## View
cat /proc/cmdline
ARM: bootargs


cd $HOME/work/ubuntu/linux ; qemu-system-x86_64 -m 4G -smp 6 -net nic -net user,hostfwd=tcp:127.0.0.1:2222-:22 -kernel /boot/vmlinuz-5.6.0-rc6-custom -append "loglevel=10 nokaslr earlyprintk console=ttyS0,115200 root=/dev/sda1 kprobe_event=p:probe/do_sys_open,do_sys_open+0,filename_ustring=+0(%si):ustring" -initrd /boot/initrd.img-5.6.0-rc6-custom -serial stdio -hda ../root.img -hdb ../home.img
