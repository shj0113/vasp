#!/bin/sh
#for ele in Co Cu Fe Mn Ni n_c n_ti ; do
for ele in *; do
	if [ -d "$ele" ]; then
		cd $ele
		env aa=$ele perl -sane 'BEGIN{$conver="no"} $energy=$F[4] if /E0/; $conver="yes" if /reached/; END{printf "%s %s %.3f \n",$ENV{aa}, $conver, $energy;}' vasp.out.relax1
		cd ..
	fi
done
#grep E0 vasp.out |tail -1 
#grep E0 vasp.out |tail -1 | perl -sane 'print "$aa $F[4] \n"' -- -aa=$ele
