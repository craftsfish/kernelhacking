The following architecture-independent constraints are used in the kernel:
r indicates that a general-purpose register is used.
m specifies that an address in memory is used.
I and J define a constant within the range 0–31 or 0–64 on IA-32 systems. This can be used for shift operations.

These constraints can be refined by using the following modifiers prefixed to the actual constraint:
= specifies that the operand may only be written. The previous value is discarded and replaced
with the output value of the operation.
+ specifies that an operand may be read and written.

static inline void set_bit(int nr, volatile unsigned long * addr)
{
	__asm__ __volatile__( LOCK_PREFIX
		"btsl %1,%0"
		:"+m" (ADDR)
		:"Ir" (nr));
}
