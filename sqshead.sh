#!/bin/sh

for i in `seq 1 10`
do
	cd try$i
	sqs2poscar bestsqs.out
	head -n 15 bestsqs.out-POSCAR
	cd ..
done
