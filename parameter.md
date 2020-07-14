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

CONFIG_CMDLINE="kprobe_event=p:probe/do_filp_open,do_filp_open+0,name=+0(+0(%si)):string"
