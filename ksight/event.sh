#!/bin/bash

on_android=$1

function run {
	echo "executing command: $@"
	if [ $on_android == 1 ] ; then
		adb shell $@
	else
		sudo $@
	fi
}
#parameters
timeout=5
func="sugov_init sugov_exit sugov_start sugov_stop sugov_limits sugov_update_shared sugov_update_single"
notrace="printk"
rand="$BASHPID-$RANDOM"

#disable trace_prink & markers
run 'echo 0 > /sys/kernel/debug/tracing/options/trace_printk'
run 'echo 0 > /sys/kernel/debug/tracing/options/markers'

#initialize
for f in $func; do
	run "echo $f >> /sys/kernel/debug/tracing/set_graph_function"
done
for f in $notrace; do
	run "echo $f >> /sys/kernel/debug/tracing/set_graph_notrace"
done
run 'echo function_graph > /sys/kernel/debug/tracing/current_tracer'

#capture
#run 'echo > /sys/kernel/debug/tracing/trace' #clear buffer
run 'echo 1 > /sys/kernel/debug/tracing/tracing_on'

sleep $timeout
run 'echo 0 > /sys/kernel/debug/tracing/tracing_on'

#finalize
run "echo > /sys/kernel/debug/tracing/set_graph_function"
run 'cat /sys/kernel/debug/tracing/trace' > /tmp/$rand
cp /tmp/$rand /tmp/l
vim /tmp/l
run 'echo nop > /sys/kernel/debug/tracing/current_tracer'
