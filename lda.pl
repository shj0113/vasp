#!/usr/bin/perl
@name=@ARGV;

$pbe="/home/sungcho/vasp/pseudopotentials/potpaw_LDA_52";

if(-f "POTCAR"){
         system"rm POTCAR";
}

foreach (@name) {
          $path="$pbe/$_";
          system("cat $path/POTCAR >> POTCAR");
}
