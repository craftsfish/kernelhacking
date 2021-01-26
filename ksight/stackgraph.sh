#!/bin/bash
trap ':' INT QUIT TERM PIPE HUP

func="kvm_vm_ioctl"
depth="3"
enable_stacktrace="1"
if [ "$enable_stacktrace" == "1" ]; then
	echo "$func:stacktrace" >> /sys/kernel/debug/tracing/set_ftrace_filter
fi
echo "$func" > /sys/kernel/debug/tracing/set_graph_function
echo "function_graph" > /sys/kernel/debug/tracing/current_tracer
echo 1 > /sys/kernel/debug/tracing/tracing_on
echo "$depth" > /sys/kernel/debug/tracing/max_graph_depth
echo "capturing trace_pipe ..."
cat /sys/kernel/debug/tracing/trace_pipe
echo "capture trace_pipe done"
echo 0 > /sys/kernel/debug/tracing/max_graph_depth
echo 0 > /sys/kernel/debug/tracing/tracing_on
echo "nop" > /sys/kernel/debug/tracing/current_tracer
echo "" > /sys/kernel/debug/tracing/set_graph_function
if [ "$enable_stacktrace" == "1" ]; then
	echo "!$func:stacktrace" >> /sys/kernel/debug/tracing/set_ftrace_filter
fi
