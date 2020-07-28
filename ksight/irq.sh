#!/bin/bash
timeout=2
events="irq nmi"
funcs="irq_enter irq_exit"
cpus="" #bit mask
sudo ./__probe.sh $timeout "$events" "$funcs" "$cpus"
