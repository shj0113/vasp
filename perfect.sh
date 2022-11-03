#!/bin/sh

for i in `seq 1 10`
do
        cd try$i
        cat bestcorr.out
        sqs2poscar bestsqs.out
        cd ..
done

