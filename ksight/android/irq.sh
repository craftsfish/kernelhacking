#!/bin/bash

#parameters
timeout=1
func="irq_enter irq_exit"
rand="$BASHPID-$RANDOM"

#disable trace_prink & markers
adb shell "echo 0 > /sys/kernel/debug/tracing/options/trace_printk"
adb shell "echo 0 > /sys/kernel/debug/tracing/options/markers"

#initialize
adb shell "echo 1 > /sys/kernel/debug/tracing/options/stacktrace"
adb shell "echo 1 > /sys/kernel/debug/tracing/events/irq/enable"
cpu=$(adb shell "cat /sys/kernel/debug/tracing/tracing_cpumask")
adb shell "echo 1 > /sys/kernel/debug/tracing/tracing_cpumask"
for f in $func; do
	adb shell "echo 'p:func_$f $f' >> /sys/kernel/debug/tracing/kprobe_events"
	adb shell "echo 1 > /sys/kernel/debug/tracing/events/kprobes/func_$f/enable"
	#adb shell "echo stacktrace > /sys/kernel/debug/tracing/events/kprobes/func_$f/trigger"
done

#capture
adb shell "echo > /sys/kernel/debug/tracing/trace #clear buffer"
adb shell "echo 1 > /sys/kernel/debug/tracing/tracing_on"
sleep $timeout
adb shell "echo 0 > /sys/kernel/debug/tracing/tracing_on"
adb shell "cat /sys/kernel/debug/tracing/trace" > /tmp/$rand #retrieve buffer

#finalize
for f in $func; do
	#adb shell "echo !stacktrace > /sys/kernel/debug/tracing/events/kprobes/func_$f/trigger"
	adb shell "echo 0 > /sys/kernel/debug/tracing/events/kprobes/func_$f/enable"
	adb shell "echo '-:func_$f' >> /sys/kernel/debug/tracing/kprobe_events"
done
adb shell "echo $cpu > /sys/kernel/debug/tracing/tracing_cpumask"
adb shell "echo 0 > /sys/kernel/debug/tracing/events/irq/enable"
adb shell "echo 0 > /sys/kernel/debug/tracing/options/stacktrace"

#dump
cp /tmp/$rand /tmp/l
vim /tmp/l
