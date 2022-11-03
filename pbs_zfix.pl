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
$ncpus = $nodes[0] * 64;

print "jobname: $text[0], compiler: $text[1], nodes: $nodes[0], time: $nodes[1]\n";

if (-e "pbs") {
    move ("pbs","pbs.bkup");
    print("previous runjob is backed up in pbs.bkup\n");
}

#$nodes[1]=$nodes*24;
open(RUNJOB,">pbs");
print RUNJOB
"#!/bin/sh
#PBS -V
#PBS -N $text[0]
#PBS -q normal
#PBS -A vasp
#PBS -l select=$nodes[0]:ncpus=$ncpus:mpiprocs=$ncpus:ompthreads=1
#PBS -l walltime=$nodes[1]:00:00

module load intel/18.0.3
module load impi/18.0.3

cd \$PBS_O_WORKDIR
exe='/home01/x1776a02/src/vasp_544_knl_zfix/bin/vasp_std'
#exe='/home01/x1776a02/src/vasp_544_skl/bin/vasp_std'

mpirun \$exe > vasp.out 2>&1
rm CHG WAVECAR
"
