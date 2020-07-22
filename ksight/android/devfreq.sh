#!/bin/bash

#disable trace_prink & markers
adb shell 'echo 0 > /sys/kernel/debug/tracing/options/trace_printk'
adb shell 'echo 0 > /sys/kernel/debug/tracing/options/markers'

#enable devfreq events
adb shell 'echo 1 > /sys/kernel/debug/tracing/events/power/bw_hwmon_meas/enable'
adb shell 'echo 1 > /sys/kernel/debug/tracing/events/power/bw_hwmon_update/enable'
adb shell 'echo 1 > /sys/kernel/debug/tracing/events/power/memlat_dev_meas/enable'
adb shell 'echo 1 > /sys/kernel/debug/tracing/events/power/memlat_dev_update/enable'

adb shell 'echo 1 > /sys/kernel/debug/tracing/tracing_on'
sleep 5
adb shell 'echo 0 > /sys/kernel/debug/tracing/tracing_on'

#disable devfreq events
adb shell 'echo 0 > /sys/kernel/debug/tracing/events/power/bw_hwmon_meas/enable'
adb shell 'echo 0 > /sys/kernel/debug/tracing/events/power/bw_hwmon_update/enable'
adb shell 'echo 0 > /sys/kernel/debug/tracing/events/power/memlat_dev_meas/enable'
adb shell 'echo 0 > /sys/kernel/debug/tracing/events/power/memlat_dev_update/enable'

adb shell 'cat /sys/kernel/debug/tracing/trace_pipe' > /tmp/a
cat /tmp/a
