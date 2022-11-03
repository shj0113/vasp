#!/bin/sh
for ele in *; do
	if [ -d "$ele" ]; then
		cd $ele
		echo $ele
		head -5  CONTCAR 
		cd ..
	fi
done
