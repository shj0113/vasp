#!/bin/sh
 #grep LOOP OUTCAR | perl -ane 'BEGIN{$sum=0;} $sum=$sum+$F[3]; END{$sum=$sum/3600; print "$sum \n";}'

 grep LOOP OUTCAR | perl -ane 'BEGIN{$sum=0;} $F[3]=~ s/://; $sum = $F[3] + $sum; END{$hour = $sum/3600; print "$hour h \n";}'
