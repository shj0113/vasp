cd conv
cd 0
pbs_hse.pl
rm -r wave
qsub pbs
cd ..

cd 1
pbs_hse.pl
rm -r wave
qsub pbs
cd ..

cd 1_ga
pbs_hse.pl
rm -r wave
qsub pbs
cd ..
cd ..


cd prim

cd 0
pbs_hse.pl
rm -r wave
qsub pbs
cd ..

cd 1
pbs_hse.pl
rm -r wave
qsub pbs
cd ..

cd 1_ga
pbs_hse.pl
rm -r wave
qsub pbs
cd ..

