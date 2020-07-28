#!/bin/bash
timeout=5
events="power/cpu_idle"
funcs=""
cpus="1" #bit mask
sudo ./__probe.sh $timeout "$events" "$funcs" "$cpus"
