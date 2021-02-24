#!/bin/bash
timeout=10
events="kvm kvmmmu"
funcs=""
cpus="" #bit mask
sudo ./__probe.sh $timeout "$events" "$funcs" "$cpus"
