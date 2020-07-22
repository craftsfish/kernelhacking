#!/bin/bash

#parameters
timeout=5
func="sugov_init sugov_exit sugov_start sugov_stop sugov_limits sugov_update_shared sugov_update_single"
notrace="printk"
rand="$BASHPID-$RANDOM"

#disable trace_prink & markers
adb shell 'echo 0 > /sys/kernel/debug/tracing/options/trace_printk'
adb shell 'echo 0 > /sys/kernel/debug/tracing/options/markers'

#initialize
for f in $func; do
	adb shell "echo $f >> /sys/kernel/debug/tracing/set_graph_function"
done
for f in $notrace; do
	adb shell "echo $f >> /sys/kernel/debug/tracing/set_graph_notrace"
done
adb shell 'echo function_graph > /sys/kernel/debug/tracing/current_tracer'

#capture
#adb shell 'echo > /sys/kernel/debug/tracing/trace' #clear buffer
adb shell 'echo 1 > /sys/kernel/debug/tracing/tracing_on'

sleep $timeout
adb shell 'echo 0 > /sys/kernel/debug/tracing/tracing_on'

#finalize
adb shell "echo > /sys/kernel/debug/tracing/set_graph_function"
adb shell 'cat /sys/kernel/debug/tracing/trace' > /tmp/$rand
adb shell 'echo nop > /sys/kernel/debug/tracing/current_tracer'
cp /tmp/$rand /tmp/l
vim /tmp/l
