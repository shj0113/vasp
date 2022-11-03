#!/bin/sh
for ele in *; do
	if [ -d "$ele" ]; then
		cd $ele
                pbs2.pl
                qsub pbs
#		env aa=$ele perl -sane 'BEGIN{$conver="no"} $energy=$F[4] if /E0/; $conver="yes" if /reached/; END{printf "%s %s %.5f \n",$ENV{aa}, $conver, $energy;}' vasp.out 
#                head -1 POSCAR
		cd ..
	fi
done
