#!/bin/sh

#modify me first!!!
func="do_sys_open"

#change directory
cd /sys/kernel/debug/tracing/

echo $func > set_graph_function
echo function_graph > current_tracer
echo > trace
echo 1 > tracing_on
sleep 10
echo 0 > tracing_on
cat trace
echo nop > current_tracer
echo > set_graph_function
