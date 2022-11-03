#!/bin/sh

mkdir zpe
cp INCAR KPOINTS POTCAR zpe
cp CONTCAR zpe/POSCAR
cd zpe
perl -i -pe 's/.*/NSW=1/ if /NSW/' INCAR
perl -i -pe 's/.*/EDIFF=1E-07/ if /EDIFF/' INCAR
perl -i -pe 's/.*// if /ISYM/; END{open(FILE,">>INCAR"); print FILE "\n ISYM=0 \n";}' INCAR
perl -i -pe 's/.*/IBRION=5/ if /IBRION/' INCAR
perl -i -pe 's/.*// if /POTIM/; END{open(FILE,">>INCAR"); print FILE "\n POTIM=0.01 \n";}' INCAR
pbs.pl
#sbatch runjob
