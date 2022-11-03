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
#SBATCH --time=72:00:00           # Runtime: Hour:Min:Sec
##

hostname
date


perl -pi -e 's/.*NELM.*//mg' INCAR
perl -pi -e 's/.*NELMIN.*//mg' INCAR
perl -pi -e 's/.*/SIGMA = 0.2/ if /SIGMA/' INCAR
perl -pi -e 's/.*/ALGO = Fast/ if /ALGO/' INCAR
perl -pi -e 's/.*/EDIFFG = -0.05/ if /EDIFFG/' INCAR

#perl -pi -e 's/.*MAGMOM.*//mg' INCAR
perl -pi -e 's/.*/ISIF = 2/ if /ISIF/' INCAR

echo 'NELM=400' >> INCAR
echo 'NELMIN=6' >> INCAR


cd \$SLURM_SUBMIT_DIR

perl -pi -e 's/.*/ICHARG=2/ if /ICHARG/' INCAR
perl -pi -e 's/.*/IBRION=-1/ if /IBRION/' INCAR
perl -pi -e 's/.*/NSW = 0/ if /NSW/' INCAR
perl -pi -e 's/.*EDIFF.*//mg' INCAR

echo 'EDIFF = 1E-08' >> INCAR
echo 'LCHARG = True' >> INCAR
echo 'ISTART = 0' >> INCAR

mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out

mkdir -p dos
cp WAVECAR CHGCAR POTCAR KPOINTS INCAR dos
cp CONTCAR dos/POSCAR
cd dos

perl -pi -e 's/.*ISIF.*//mg' INCAR
perl -pi -e 's/.*/ICHARG=11/ if /ICHARG/' INCAR
perl -pi -e 's/.*/ISMEAR=5/ if /ISMEAR/' INCAR
perl -pi -e 's/.*/ISTART=1/ if /ISTART/' INCAR
echo 'NEDOS = 3000' >> INCAR

mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out









"
