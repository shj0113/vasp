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
$nodes[1] ||= "24";


print "$text[0], $text[1], $nodes[0], $nodes[1]\n";

if (-e "runjob") {
    move ("runjob","runjob.bkup");
    print("previous runjob is backed up in runjob.bkup\n");
}

$nodes[1]=$nodes[0]*24;
open(RUNJOB,">runjob");
print RUNJOB
"#!/bin/bash
#SBATCH --job-name=$text[0]
#SBATCH --partition=shared
#SBATCH --nodes=$nodes[0]
#SBATCH --tasks-per-node=12
#SBATCH --export=ALL
#SBATCH -e vasp.err
#SBATCH -t $nodes[1]:00:00
#SBATCH -A TG-DMR160007

#Generate a hostfile from the slurm node list
export \$SLURM_NODEFILE
#Run the job using mpirun_rsh

#module unload intel/2013_sp1.2.144
#module load intel/2015.2.164
#module unload mvapich2_ib
#module load openmpi_ib/1.8.4
#ibrun -n \$processors ~/vasp/vasp_std >& vasp.out

module unload intel
module load vasp
run_vasp -c 'mpirun -np $nodes[0] -genv I_MPI_FABRICS shm:ofa /opt/vasp/5.4.1.20160205/bin/vasp_std' relax static
"
