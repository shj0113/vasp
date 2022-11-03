#!/bin/sh

for i in `seq 0.25 0.25 0.75`
do
        mkdir -p band$i
        cd $i
        #cp POSCAR ../band$i
        cp CONTCAR ../band$i
        cp POTCAR ../band$i
        #mv KPOINTS1 ../band$i
        cd ..
	cp KPOINTS.prim band$i
	cp BANDINCAR band$i
	cd band$i
	mv BANDINCAR INCAR
        mv CONTCAR POSCAR
        mv KPOINTS.prim KPOINTS
        pbs.pl
        qsub pbs
        cd ..
done

