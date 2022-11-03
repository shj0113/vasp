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
#SBATCH --ntasks-per-node=32      # Cores per node
#SBATCH --partition=cascade2       # Partition Name
##
#SBATCH --job-name=$jobname	  # job name
#SBATCH --time=300:00:00           # Runtime: Hour:Min:Sec
##

hostname
date

cd \$SLURM_SUBMIT_DIR
mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out

mkdir -p hse
cp INCAR POTCAR hse
mv WAVECAR CHGCAR hse
cp CONTCAR hse/POSCAR
cp IBZKPT hse/KPOINTS


cd hse


perl -pi -e 's/.*EDIFF.*//mg' INCAR
echo 'EDIFF=1E-05' >> INCAR
echo 'EDIFFG=-0.01' >> INCAR

perl -pi -e 's/.*/ICHARG=11/ if /ICHARG/' INCAR
perl -pi -e 's/.*/NSW = 0/ if /NSW/' INCAR
perl -pi -e 's/.*/LWAVE = False/ if /LWAVE/' INCAR
perl -pi -e 's/.*/LCHARG = False/ if /LCHARG/' INCAR


echo 'LHFCALC = .TRUE.' >> INCAR
echo 'AEXX   =  0.32' >> INCAR
echo 'HFSCREEN = 0.2' >> INCAR
echo 'TIME = 0.4' >> INCAR
echo 'PRECFOCK=N' >> INCAR
perl -pi -e 's/.*/ALGO=A/ if /ALGO/' INCAR

mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out


"
