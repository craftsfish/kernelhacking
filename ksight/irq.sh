#!/bin/bash

#parameters
timeout=5
func="irq_enter irq_exit"
rand="$BASHPID-$RANDOM"

#disable trace_prink & markers
echo 0 > /sys/kernel/debug/tracing/options/trace_printk
echo 0 > /sys/kernel/debug/tracing/options/markers

#initialize
echo 1 > /sys/kernel/debug/tracing/options/stacktrace
echo 1 > /sys/kernel/debug/tracing/events/irq/enable
echo 1 > /sys/kernel/debug/tracing/events/nmi/enable
cpu=$(cat /sys/kernel/debug/tracing/tracing_cpumask)
echo 1 > /sys/kernel/debug/tracing/tracing_cpumask
for f in $func; do
	echo "p:func_$f $f" >> /sys/kernel/debug/tracing/kprobe_events
	echo 1 > /sys/kernel/debug/tracing/events/kprobes/func_$f/enable
	#echo stacktrace > /sys/kernel/debug/tracing/events/kprobes/func_$f/trigger
done

#capture
echo > /sys/kernel/debug/tracing/trace #clear buffer
echo 1 > /sys/kernel/debug/tracing/tracing_on
sleep $timeout
echo 0 > /sys/kernel/debug/tracing/tracing_on
cat /sys/kernel/debug/tracing/trace > /tmp/$rand #retrieve buffer

#finalize
for f in $func; do
	#echo !stacktrace > /sys/kernel/debug/tracing/events/kprobes/func_$f/trigger
	echo 0 > /sys/kernel/debug/tracing/events/kprobes/func_$f/enable
	echo "-:func_$f" >> /sys/kernel/debug/tracing/kprobe_events
done
echo $cpu > /sys/kernel/debug/tracing/tracing_cpumask
echo 0 > /sys/kernel/debug/tracing/events/nmi/enable
echo 0 > /sys/kernel/debug/tracing/events/irq/enable
echo 0 > /sys/kernel/debug/tracing/options/stacktrace

#dump
cp /tmp/$rand /tmp/l
vim /tmp/l
