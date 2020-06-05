#!/bin/sh

aaa=1
if test $aaa -eq 0 -a 1 -eq 0
then
	echo "a"
else
	echo "b"
fi

my_func () {
	echo $@
}

my_func xxx bbb

if test $# -ne 0; then
	echo $#
fi

bbb=$(($aaa + 3))
echo $bbb

while test $aaa -eq 0 -a $bbb -eq 0 ; do
	echo "hit"
done
