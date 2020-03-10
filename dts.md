# Device Tree

This document details device tree related operations.

## of_address_to_resource
```
/	#address-cells = <1>; #size-cells = <1>;
|----soc	#address-cells = <1>; #size-cells = <1>;	ranges = <0x7e000000 0x3f000000 0x01000000>, <0x40000000 0x40000000 0x00040000>;
     |----uart0 reg = <0x7e201000 0x1000>;
```
start : 0x7e201000 - 0x7e000000 + 0x3f000000 = 0x3f201000\
end : start + 0x1000 - 1 = 0x3f201fff\
PS : if there is more than one `ranges` during the path from `uart0` to `/`, repeat such process until it reachs the root.

## of_platform_populate
Assume / is a bus, populate all devices under it as platform_device.\
If new device is a bus, repeat the previous step.
