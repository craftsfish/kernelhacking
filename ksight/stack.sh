#!/bin/bash
timeout=1
events=""
funcs="do_filp_open"
cpus="" #bit mask
sudo ./__probe.sh $timeout "$events" "$funcs" "$cpus"
