#!/bin/sh

for i in `seq 1 10`
do
        cd try$i
        lattice.py bestsqs.out-POSCAR
        cd ..
done
