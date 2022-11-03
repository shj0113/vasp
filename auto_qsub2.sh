#!/bin/sh
for ele in *; do
        if [ -d "$ele" ]; then
                cd $ele
#               env aa=$ele perl -sane 'BEGIN{$conver="no"} $energy=$F[4] if /E0/; $conver="yes" if /reached/; END{printf "%s %s %.5f \n",$ENV{aa}, $conver, $energy;}' vasp.out
                pbs2.pl
                qsub pbs
#                cat KPOINTS
                cd ..
        fi
done

