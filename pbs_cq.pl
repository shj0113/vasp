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
#SBATCH --ntasks-per-node=24      # Cores per node
#SBATCH --partition=cascade       # Partition Name
##
#SBATCH --job-name=$jobname	  # job name
#SBATCH --time=300:00:00           # Runtime: Hour:Min:Sec
##


hostname
date

cd \$SLURM_SUBMIT_DIR
mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out

#mkdir -p scf
#cp INCAR KPOINTS POTCAR scf
#cp CONTCAR scf/POSCAR
#perl -pi -e 's/.*CHARG=True/ if /CHARG/' INCAR
#perl -pi -e 's/.*/NSW = 0/ if /NSW/' INCAR
#cd scf

#mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out

mkdir -p dos
cp INCAR KPOINTS POTCAR CHGCAR dos
cp CONTCAR dos/POSCAR
cd dos
perl -pi -e 's/.*/NSW = 0/ if /NSW/' INCAR
perl -pi -e 's/.*/ICHARG = 11/ if /ICHARG/' INCAR
perl -pi -e 's/.*/IBRION = -1/ if /IBRION/' INCAR
#perl -pi -e 's/.*/EDIFF = 1E-08/ if /-08/' INCAR
perl -pi -e 's/.*/ISYM = 2/ if /ISYM/' INCAR
perl -pi -e 's/.*/SIGMA = 0.1/ if /SIGMA/' INCAR

perl -pi -e 's/.*/12 12 1/ if /4/' KPOINTS

echo 'NEDOS = 3001' >> INCAR

#perl -pi -e 's/.*/LVTOT = True/ if /LVTOT/' INCAR
#echo 'LVTOT = TRUE' >> INCAR
cp ~/bin/dosdat.py .
cp ~/bin/test.py .

mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out
"
