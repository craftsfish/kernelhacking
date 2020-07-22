#!/bin/bash

#parameters
timeout=5
func="scheduler_tick"
rand="$BASHPID-$RANDOM"

#disable trace_prink & markers
adb shell 'echo 0 > /sys/kernel/debug/tracing/options/trace_printk'
adb shell 'echo 0 > /sys/kernel/debug/tracing/options/markers'

#initialize
for f in $func; do
	adb shell "echo 'p:func_$f $f' >> /sys/kernel/debug/tracing/kprobe_events"
	adb shell "echo 1 > /sys/kernel/debug/tracing/events/kprobes/func_$f/enable"
	adb shell "echo stacktrace > /sys/kernel/debug/tracing/events/kprobes/func_$f/trigger"
done

#capture
adb shell 'echo > /sys/kernel/debug/tracing/trace' #clear buffer
adb shell 'echo 1 > /sys/kernel/debug/tracing/tracing_on'
sleep $timeout
adb shell 'echo 0 > /sys/kernel/debug/tracing/tracing_on'
adb shell 'cat /sys/kernel/debug/tracing/trace' > /tmp/$rand #retrieve buffer

#finalize
for f in $func; do
	adb shell "echo !stacktrace > /sys/kernel/debug/tracing/events/kprobes/func_$f/trigger"
	adb shell "echo 0 > /sys/kernel/debug/tracing/events/kprobes/func_$f/enable"
	adb shell "echo '-p:func_$f $f' >> /sys/kernel/debug/tracing/kprobe_events"
done

#dump
cp /tmp/$rand /tmp/l
vim /tmp/l
