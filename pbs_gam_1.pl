#!/usr/bin/env perl

use File::Copy;
use Cwd;

for (1 .. 4) {
        $tmp = shift;
        push @text,$tmp if $tmp =~ /[a-zA-Z]/;
        push @nodes,$tmp if $tmp =~ /^\d/;
}
$jobname = getcwd;
if ($jobname =~ /\//) {
        @temp =  split /\//, $jobname;
        $jobname = $temp[-1];
}

$text[0] ||= $jobname;
$text[1] ||= "vasp_std";
$nodes[0] ||= "1";
$nodes[1] ||= "48";
$cores[0] ||= "24";

print "jobname: $text[0], compiler: $text[1], nodes: $nodes[0], time: $nodes[1]\n";

if (-e "pbs") {
    move ("pbs","pbs.bkup");
    print("previous runjob is backed up in pbs.bkup\n");
}

#$nodes[1]=$nodes*24;
open(RUNJOB,">pbs");
print RUNJOB
"#!/bin/bash
#SBATCH --nodes=1 		  # Nodes 
#SBATCH --ntasks-per-node=$cores[0]      # Cores per node
#SBATCH --partition=cascade       # Partition Name
##
#SBATCH --job-name=$jobname	  # job name
#SBATCH --time=300:00:00           # Runtime: Hour:Min:Sec
##

hostname
date

#perl -pi -e 's/.*NPAR.*//mg' INCAR
perl -pi -e 's/.*NELM.*//mg' INCAR
perl -pi -e 's/.*ICHARG.*//mg' INCAR
#perl -pi -e 's/.*MAGMOM.*//mg' INCAR
perl -pi -e 's/.*IVDW.*//mg' INCAR


perl -pi -e 's/.*NELMIN.*//mg' INCAR
perl -pi -e 's/.*/SIGMA = 0.2/ if /SIGMA/' INCAR
perl -pi -e 's/.*/ALGO = Fast/ if /ALGO/' INCAR
perl -pi -e 's/.*/ISIF = 2/ if /ISIF/' INCAR
perl -pi -e 's/.*/EDIFFG = -0.05/ if /EDIFFG/' INCAR
perl -pi -e 's/.*/NSW = 200/ if /NSW/' INCAR


echo 'NELM=200' >> INCAR
echo 'NELMIN=6' >> INCAR
echo 'IVDW=1' >> INCAR


cd \$SLURM_SUBMIT_DIR
##mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out
mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/AVX512/vasp.5.4.4.pl2.O3.AVX512.gam.x > vasp.out
mkdir -p 111
cp KPOINTS KPOINTS_331 POTCAR INCAR 111
cp CONTCAR 111/POSCAR
cd 111
perl -pi -e 's/.*/LWAVE = True/ if /LWAVE/' INCAR


mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out

mkdir -p 331

cp WAVECAR POTCAR INCAR 331
cp CONTCAR 331/POSCAR
cp KPOINTS_331 331/KPOINTS

#cd 331

#mpirun -np \$NP -machinefile \$PBS_NODEFILE \$vasp >> vasp.out
#
"
