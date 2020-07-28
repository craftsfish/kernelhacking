#!/bin/bash
timeout=1
events="power/cpu_idle irq"
funcs="irq_enter irq_exit"
cpus="" #bit mask
sudo ./__probe.sh $timeout "$events" "$funcs" "$cpus"
