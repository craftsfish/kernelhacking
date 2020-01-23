#!/bin/bash

set -e
tmpfile=$(mktemp)
trap "rm -f $tmpfile" 0 INT QUIT ABRT PIPE TERM
for i in $(ls .); do
	if [[ "$i" != "sort.sh" ]] ; then
		echo "$i -> $tmpfile"
		cat $i | sort -u > $tmpfile
		cat $tmpfile > $i
	fi
done
