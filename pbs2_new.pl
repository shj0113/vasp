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
$cores[0] ||= "32";

print "jobname: $text[0], compiler: $text[1], nodes: $nodes[0], time: $nodes[1]\n";

if (-e "pbs") {
    move ("pbs","pbs.bkup");
    print("previous runjob is backed up in pbs.bkup\n");
}
open(RUNJOB,">pbs");
print RUNJOB
"#!/bin/bash
#SBATCH --nodes=$nodes[0]                 # Nodes
#SBATCH --ntasks-per-node=$cores[0]      # Cores per node
#SBATCH --partition=cascade2       # Partition Name
##
#SBATCH --job-name=$jobname       # job name
#SBATCH --time=48:00:00           # Runtime: Hour:Min:Sec
##

hostname
date

module add Compiler/intel/19.1.3.304
module add MKL/2020.4.304
module add MPI/intel/2019.9.304

#perl -pi -e 's/.*NPAR.*//mg' INCAR


cd \$SLURM_SUBMIT_DIR
mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/6.2.0/O3/AVX2/vasp.6.2.0.O3.AVX2.std.x > vasp.out
"
