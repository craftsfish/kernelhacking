# Understanding the Linux Kernel (3rd Edition)

# Chapter 8 Memory Management
## Cache Descriptor
p326, 一个cache中包含多个slab，一个slab可能包含多个物理上连续的page，一个slab里面包含了多个要分配的object
slab的page能否是high memory？不能，slab cache分配的内存空间是直接给内核使用的，必须有对应的虚拟地址，而high memory没有经过映射是没有虚拟地址的。
