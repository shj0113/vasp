#!/bin/bash

mypwd=`pwd`
#echo ${mypwd##/*/}


for i in `seq 1 7`

do
        mkdir -p ${mypwd##/*/}_$i
        cp p$i ${mypwd##/*/}_$i
        cd ${mypwd##/*/}_$i
        cp p$i POSCAR
#        bulk.py
        cp ../INCAR .
        cp ../KPOINTS .
        cp ../POTCAR .
        pbs2.pl
        qsub pbs
        cd ..
done

