#!/bin/sh

func="do_execve"
cd /sys/kernel/debug/tracing/
echo "p:$func $func" >> kprobe_events
echo 'stacktrace' > events/kprobes/$func/trigger
echo 1 > events/kprobes/$func/enable
echo $func > set_graph_function
echo function_graph > current_tracer
echo > trace
echo 1 > tracing_on
sleep 5
echo 0 > tracing_on
cat trace
echo nop > current_tracer
echo > set_graph_function
echo 0 > events/kprobes/$func/enable
echo '!stacktrace' > events/kprobes/$func/trigger
echo "-:$func" >> kprobe_events
