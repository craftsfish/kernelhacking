# Misc

This document lists uncategorized notes when hacking kernel.

## Kernel Preemption
An involuntarily relinquish of CPU because of a higher priority process becomes runnable (typically triggered by an interrupt).

## Memory Management
- All allocable page frames are managed by buddy system.
- Slab allocator provides memory allocation of refined granuality based on buddy system.
- Cache function is provided by slab allocator to improve performance. Both per-CPU and cross-CPU caches are supported.
- Memory pool is build upon the aboving 2 allocation system and allocate memory form it's reserved area when the aboving 2 methods failed.

## High Memory
- To build the mapping between virtual address and high memory, 3 methods are provided as following:
- Permanent kernel mappings, cross-CPU
- Temporary kernel mappings, per-CPU, specified by km_type
- Noncontiguous memory allocation, using vmalloc to get an contiguous virtual address space and map with page frames

#PGD of kernel space
- Each process's PGD of kernel space is same as master kernel PGD
- When alloating new address space, manifest PTE inforamtion in master kernel PGD and when user process trying to visit it, synchronization is triggered by page fault.
- When releasing address space, PUD, PMD and PTD of kernel space are shared between all user spaces, so clear PTE is ok for all processes.
