#!/bin/bash
target="firefox"
event=""
filter=""

cd /sys/kernel/debug/tracing

parameters=(
	#dumpstack, event, filter fields...
	"0 sched_process_exec"
	"0 sched_process_exit comm"
	#"0 sched_process_fork parent_comm child_comm"
	"0 sched_process_fork"
	"0 sched_process_free comm"
	"0 sched_process_hang comm"
	"0 sched_process_wait comm"
	"0 sched_stat_blocked comm"
	"0 sched_stat_iowait comm"
	"0 sched_stat_runtime comm"
	"0 sched_stat_sleep comm"
	"0 sched_stat_wait comm"
	"0 sched_switch prev_comm next_comm"
	"0 sched_wait_task comm"
	"0 sched_wake_idle_without_ipi"
	"0 sched_wakeup comm"
	"0 sched_wakeup_new comm"
	"0 sched_waking comm"
)

if [[ "$1" == "enable" ]]; then
	echo > trace
	echo 1 > tracing_on
else
	echo 0 > tracing_on
fi

#enable
for ps in "${parameters[@]}"; do
	i=0
	event=""
	filter=""
	stack=0
	for p in $ps; do
		if ((i==0)) ; then
			stack=$p
		elif ((i==1)) ; then
			event=$p
		else
			if ((i>2)) ; then
				filter="${filter} || "
			fi
			filter="${filter}$p == $target"
		fi
		((i++))
	done

	if [[ "$1" == "enable" ]]; then
		echo 1 > events/sched/$event/enable
		if [[ "$filter" != "" ]] ; then
			echo "$filter" > events/sched/$event/filter
			if (( $stack == 1 )) ; then echo "stacktrace if ($filter)" > events/sched/$event/trigger ; fi
			#cat events/sched/$event/filter
			#cat events/sched/$event/trigger
		else
			if (( $stack == 1 )) ; then echo "stacktrace" > events/sched/$event/trigger ; fi
		fi
	else
		echo 0 > events/sched/$event/enable
		if [[ "$filter" != "" ]] ; then
			echo 0 > events/sched/$event/filter
			if (( $stack == 1 )) ; then echo "!stacktrace if ($filter)" > events/sched/$event/trigger ; fi
		else
			if (( $stack == 1 )) ; then echo "!stacktrace" > events/sched/$event/trigger ; fi
		fi
	fi
done
