#!/bin/sh

for i in `seq 1 10`
do
        cd try$i
        head -n 5 bestsqs.out-POSCAR
        cd ..
done

