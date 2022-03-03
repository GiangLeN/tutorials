#!/bin/bash

FLIP=$(($(($RANDOM%10))%2))


if [ $FLIP -eq 1 ]
then
	echo "Result" > out.txt
else
	touch out.txt
fi
