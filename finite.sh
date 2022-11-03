#!/bin/sh


for i in `seq -f "%03g" 20`
do
	mkdir -p disp-$i
	cp INCAR KPOINTS POTCAR POSCAR-$i disp-$i
	cd disp-$i
	mv POSCAR-$i POSCAR
	pbs.pl
	qsub pbs
	cd ..
done

