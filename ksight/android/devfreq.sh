#!/bin/bash

#disable trace_prink & markers
adb shell 'echo 0 > /sys/kernel/debug/tracing/options/trace_printk'
adb shell 'echo 0 > /sys/kernel/debug/tracing/options/markers'

#events="bw_hwmon_meas bw_hwmon_update memlat_dev_meas memlat_dev_update"
events="bw_hwmon_meas bw_hwmon_update"

#enable devfreq events
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

adb shell 'cat /sys/kernel/debug/tracing/trace_pipe' > /tmp/a
cat /tmp/a
