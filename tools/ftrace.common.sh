#!/bin/bash
if (($(id -u) != 0)) ; then echo "please run as root"; exit ; fi

#modify following variables
module="block"
parameters=(
	#dumpstack, event, filter fields...
	"1 block_bio_backmerge"
	"1 block_bio_bounce"
	"1 block_bio_complete"
	"1 block_bio_frontmerge"
	"1 block_bio_queue"
	"1 block_bio_remap"
	"1 block_dirty_buffer"
	"1 block_getrq"
	"1 block_plug"
	"1 block_rq_complete"
	"1 block_rq_insert"
	"1 block_rq_issue"
	"1 block_rq_remap"
	"1 block_rq_requeue"
	"1 block_sleeprq"
	"1 block_split"
	"1 block_touch_buffer"
	"1 block_unplug"
)

cd /sys/kernel/debug/tracing
if [[ "$1" == "1" ]]; then
	echo > trace
	echo 1 > tracing_on
elif [[ "$1" == "0" ]]; then
	echo 0 > tracing_on
	cat trace > /tmp/trace
else
	echo "usage: 1/0"
fi

event=""
filter=""

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

	if [[ "$1" == "1" ]]; then
		echo 1 > events/$module/$event/enable
		if [[ "$filter" != "" ]] ; then
			echo "$filter" > events/$module/$event/filter
			if (( $stack == 1 )) ; then echo "stacktrace if ($filter)" > events/$module/$event/trigger ; fi
			#cat events/$module/$event/filter
			#cat events/$module/$event/trigger
		else
			if (( $stack == 1 )) ; then echo "stacktrace" > events/$module/$event/trigger ; fi
			#cat events/$module/$event/trigger
		fi
	else
		echo 0 > events/$module/$event/enable
		if [[ "$filter" != "" ]] ; then
			echo 0 > events/$module/$event/filter
			if (( $stack == 1 )) ; then echo "!stacktrace if ($filter)" > events/$module/$event/trigger ; fi
		else
			if (( $stack == 1 )) ; then echo "!stacktrace" > events/$module/$event/trigger ; fi
		fi
	fi
done
