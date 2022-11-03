#!/usr/bin/perl
@name=@ARGV;
#$pbe="/home/khw/src/pseudopotentials/potpaw_PBE_52";
#$pbe="/home/khw/src/atomate/MY_PSP/POT_GGA_PAW_PBE_54";
#$pbe="/home/khw/src/POTCAR/3.POTPAW.LDA.PBE.52.54.ORIG/potpaw.52";
$pbe="/home/khw/src/POTCAR/2.POTPAW.PBE.54.RECOMMEND";
#$pbe="/home/khw/src/atomate/MY_PSP
if(-f "POTCAR"){
         system"rm POTCAR";
}

foreach (@name) {
          $path="$pbe/$_";
          system("cat $path/POTCAR >> POTCAR");
}
