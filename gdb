hbreak xxx
commands
p xxx
continue
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
add-auto-load-safe-path ./scripts/gdb/vmlinux-gdb.py
file ./vmlinux
target remote :1234
hbreak start_kernel
