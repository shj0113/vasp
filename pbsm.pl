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
#SBATCH --nodes=2 		  # Nodes 
#SBATCH --ntasks-per-node=24      # Cores per node
#SBATCH --partition=cascade       # Partition Name
##
#SBATCH --job-name=$jobname	  # job name
#SBATCH --time=300:00:00           # Runtime: Hour:Min:Sec
##
#SBATCH --mail-user=happyday9805\@naver.com
#SBATCH --mail-type=ALL
#SBATCH --mail-type=END
#

hostname
date

#perl -pi -e 's/.*NPAR.*//mg' INCAR

cd \$SLURM_SUBMIT_DIR
#mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out

mpirun -np \$SLURM_NTASKS -genv I_MPI_FABRICS \"shm:tcp\" /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out
#rm WAVECAR CHGCAR CHG
"
