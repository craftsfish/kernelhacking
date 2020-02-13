#!/bin/bash

for i in $(ls .); do
	if [[ "$i" != "install.sh" ]] ; then
		echo "installing $i ..."
		sudo cp $i /usr/local/bin
	fi
done
