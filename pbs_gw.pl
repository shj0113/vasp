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

perl -pi -e 's/.*MAGMOM.*//mg' INCAR
perl -pi -e 's/.*LORBIT.*//mg' INCAR
perl -pi -e 's/.*LDAUPRINT.*//mg' INCAR
#perl -pi -e 's/.*LASPH.*//mg' INCAR
perl -pi -e 's/.*ICHARG.*//mg' INCAR
perl -pi -e 's/.*ISPIN.*//mg' INCAR

#perl -pi -e 's/.*/LREAL = Auto/ if /LREAL/' INCAR


cd \$SLURM_SUBMIT_DIR
mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out

mkdir -p dvo
cp CHGCAR LOCPOT WAVECAR INCAR KPOINTS POTCAR dvo
cp CONTCAR dvo/POSCAR
cd dvo

perl -pi -e 's/.*NCORE.*//mg' INCAR #LDA Parameter delete
perl -pi -e 's/.*LDA.*//mg' INCAR #LDA Parameter delete
perl -pi -e 's/.*LMAXMIX.*//mg' INCAR
perl -pi -e 's/.*NSW.*//mg' INCAR
perl -pi -e 's/.*ENCUT.*//mg' INCAR
perl -pi -e 's/.*NELMIN.*//mg' INCAR
perl -pi -e 's/.*ISIF.*//mg' INCAR
perl -pi -e 's/.*ENCUT.*//mg' INCAR
perl -pi -e 's/.*EDIFFG.*//mg' INCAR


perl -pi -e 's/.*/NELM = 1/ if /NELM =/' INCAR
perl -pi -e 's/.*/ALGO = Exact/ if /ALGO/' INCAR

echo 'LOPTICS=True' >> INCAR
echo 'NEDOS=2000' >> INCAR

mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out

mkdir -p gw
cp CHGCAR LOCPOT INCAR KPOINTS POTCAR WAVECAR WAVEDER gw
cp CONTCAR gw/POSCAR
cd gw

perl -pi -e 's/.*/ALGO = GW0/ if /ALGO/' INCAR
echo 'LSPECTRAL = True' >> INCAR
echo 'NOMEGA = 60' >> INCAR
echo '! LWANNIER90=True' >> INCAR

mpirun -np \$SLURM_NTASKS /TGM/Apps/VASP/bin/5.4.4/O3/NORMAL/vasp.5.4.4.pl2.O3.NORMAL.std.x > vasp.out
"
