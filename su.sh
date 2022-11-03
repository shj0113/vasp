#!/bin/sh
 grep LOOP OUTCAR | perl -ane 'BEGIN{$sum=0;} $sum=$sum+$F[3]; END{$sum=$sum/3600*12; print "$sum \n";}'

