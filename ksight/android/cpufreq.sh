#!/bin/bash

model=$(adb shell 'getprop ro.product.name')

events="cpu_frequency"
if [ $model == PCRM00 ]; then
	events="$events sugov_next_freq_lcj sugov_util_update"
else
	events="$events sugov_next_freq sugov_util_update"
fi

#disable trace_prink & markers
adb shell 'echo 0 > /sys/kernel/debug/tracing/options/trace_printk'
adb shell 'echo 0 > /sys/kernel/debug/tracing/options/markers'

#enable devfreq events
#adb shell "echo 1 > /sys/kernel/debug/tracing/options/stacktrace"
for i in $events; do
	adb shell "echo 1 > /sys/kernel/debug/tracing/events/power/$i/enable"
done

adb shell 'echo 1 > /sys/kernel/debug/tracing/tracing_on'
sleep 5
adb shell 'echo 0 > /sys/kernel/debug/tracing/tracing_on'

#disable devfreq events
for i in $events; do
	adb shell "echo 0 > /sys/kernel/debug/tracing/events/power/$i/enable"
done
adb shell "echo 0 > /sys/kernel/debug/tracing/options/stacktrace"

adb shell 'cat /sys/kernel/debug/tracing/trace' > /tmp/a
mv /tmp/a cpu.log
