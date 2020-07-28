#!/bin/bash

#parameters
timeout="$1"
events="$2"
funcs="$3"
cpus="$4"
rand="$BASHPID-$RANDOM"

#disable trace_prink & markers
echo 0 > /sys/kernel/debug/tracing/options/trace_printk
echo 0 > /sys/kernel/debug/tracing/options/markers

#initialize
echo 1 > /sys/kernel/debug/tracing/options/stacktrace
cpu=$(cat /sys/kernel/debug/tracing/tracing_cpumask)
if [ "$cpus" != "" ]; then
	echo $cpus > /sys/kernel/debug/tracing/tracing_cpumask
fi
for e in $events; do
	echo 1 > /sys/kernel/debug/tracing/events/$e/enable
done
for f in $funcs; do
	echo "p:func_$f $f" >> /sys/kernel/debug/tracing/kprobe_events
	echo 1 > "/sys/kernel/debug/tracing/events/kprobes/func_$f/enable"
done

#capture
echo > /sys/kernel/debug/tracing/trace #clear buffer
echo 1 > /sys/kernel/debug/tracing/tracing_on
sleep $timeout
echo 0 > /sys/kernel/debug/tracing/tracing_on
cat /sys/kernel/debug/tracing/trace > /tmp/$rand #retrieve buffer

#finalize
for f in $funcs; do
	echo 0 > "/sys/kernel/debug/tracing/events/kprobes/func_$f/enable"
	echo "-:func_$f" >> /sys/kernel/debug/tracing/kprobe_events
done
for e in $events; do
	echo 0 > /sys/kernel/debug/tracing/events/$e/enable
done
echo $cpu > /sys/kernel/debug/tracing/tracing_cpumask
echo 0 > /sys/kernel/debug/tracing/options/stacktrace

#dump
mv /tmp/$rand ./probe.log
vim ./probe.log
