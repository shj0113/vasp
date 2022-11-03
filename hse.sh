#!/bin/sh

for i in `seq 0.25 0.25 0.75`
do
        mkdir -p hse$i
        cd $i
        #cp POSCAR ../hse$i
        cp CONTCAR ../hse$i
        cp POTCAR ../hse$i
        cp IBZKPT KPOINTS1
        mv KPOINTS1 ../hse$i
        cd ..
        cp HSEINCAR hse$i
        cd hse$i
	mv HSEINCAR INCAR
        mv CONTCAR POSCAR
        mv KPOINTS1 KPOINTS
        pbs.pl
        qsub pbs
        cd ..
done

