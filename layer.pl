#!/usr/bin/perl
#This code generates LAYERS file
#written by S.B. Cho in Hanyang University.
#if you have any question email to csb444@hanyang.ac.kr
#This code is written in May 12 2015

#check the LAYER file and make backup
if (-e "LAYERS"){
	system("mv LAYERS LAYERS.bkup");
	print "The LAYER is backed up.\n";
};


#check the number of elements
open($contcar,"<CONTCAR");
$line=<$contcar> for (1 .. 7);
@num_atoms=split(/\s+/,$line);
shift @num_atoms;
#print "@num_atoms\n";
close($contar);

for($i=0;$i<@num_atoms;$i++){
	for($j=0;$j<=$i;$j++){
		$num_atoms1[$i]+=$num_atoms[$j];
	}
}
unshift @num_atoms1,'0';
#print "@num_atoms1\n";
$num_layers = $#num_atoms + 1;

open($layers,">LAYERS");
print $layers " .TRUE.       ! total DOS\n";
print $layers " .TRUE.       ! LDOS\n";
print $layers " .FALSE.      ! Normalize LDOS (meaning LDOS/NATOM)\n";
print $layers " .FALSE.      ! PDOS\n";
print $layers "$num_layers  ! number of layers\n";
print $layers ".FALSE.      ! LRANGE (range if .TRUE.; atom indices if .FALSE.)\n";
print $layers "@num_atoms  ! number of atoms\n";

for($k=0;$k<@num_atoms1;$k++){
	for($i=$num_atoms1[$k];$i<$num_atoms1[$k+1];$i++){
		$a=$i+1;
		print $layers "$a ";
	}
	print $layers "\n";
}
close($layers);

system("pdos.x");
$path='/home/sungcho/code/gnuplot/';
open(AA,'>dos.plt');
print AA "set terminal pngcairo enhanced font 'Verdana,20' size 1980,1080
set output 'dos.png'";
#print AA "set term dumb\n";
#print AA "set term pdf enhanced font \'Times,9\'\n";
#print AA "set output \'o-t.pdf\'\n";
#set terminal pngcairo size 350,262 enhanced font 'Verdana,10'

print AA "
# set path of config snippets
set loadpath '$path'
# # load config snippets
load 'gnuplot-palettes/set1.pal'
load 'xyborder.cfg'
load 'grid.cfg'
load 'mathematics.cfg'
";

print AA "set xrange \[-3:3\] \n";
print AA "set yrange \[-3:3\] \n";
print AA "set xlabel 'energy (eV)' \n";
print AA "set ylabel \"DOS \(states/eV\)\" \n";
print AA "set style fill transparent solid 0.4 noborder \n";
#print AA "set arrow from 0,0 to 0,4.5 lw 2 lt \"dashed\" nohead\n";

print AA " plot ";
print AA "'ldos.dat03' u 1:10 w l ls 1 lw 2 title 'd_{xy}' ,\\\n";
print AA "'ldos.dat03' u 1:11 w l ls 1 lw 2 notitle ,\\\n";

print AA "'ldos.dat03' u 1:12 w l ls 2 lw 2 title 'd_{yz}' ,\\\n";
print AA "'ldos.dat03' u 1:13 w l ls 2 lw 2 notitle ,\\\n";

print AA "'ldos.dat03' u 1:16 w l ls 3 lw 2 title 'd_{zx}' ,\\\n";
print AA "'ldos.dat03' u 1:17 w l ls 3 lw 2 notitle ,\\\n";

print AA "'ldos.dat03' u 1:14 w l ls 4 lw 2 title 'd_{z^2}' ,\\\n";
print AA "'ldos.dat03' u 1:15 w l ls 4 lw 2 notitle ,\\\n";

print AA "'ldos.dat03' u 1:18 w l ls 5 lw 2 title 'd_{x^2-y^2}' ,\\\n";
print AA "'ldos.dat03' u 1:19 w l ls 5 lw 2 notitle ,\\\n";


@dos = glob ("*dos\.dat*");
for $i (@dos) {
system("perl -pi -e 's/D/E/g' $i");
}


#print AA "'ldos.dat05' u 1:20 w filledcurves above y1=0 ls 6 title 'O' ,\\\n";
#print AA "'ldos.dat05' u 1:21 w filledcurves below y1=0 ls 6 notitle ,\\\n";

#system('gnuplot dos.plt');
#system('eog dos.png');

=pod

for $i (3) {
         print AA "\'ldos.dat0$i\' u 1:(\$10-\$11+\$12-\$13+\$14-\$15+\$16-\$17+\$18-\$19) w l lc rgb \"#339933\" title \' ldos$i  \' ";
		 #print AA "\'ldos.dat0$i\' u 1:20 w filledcurves above y1=0 lc rgb \"#339933\" title \' ldos$i  \' \, ";
		 #print AA "\'ldos.dat0$i\' u 1:21 w filledcurves below y1=0 lc rgb \"#339933\" title \' ldos$i  \' \, ";
print AA "\'ldos.dat0$a\' u 1:20 w filledcurves above y1=0 lc rgb \"#339933\" title \'C \(Asite\)\' \,";
#         print AA "\'ldos.dat0$a\' u 1:2 w filledcurves above y1=0 \,";
#         print AA "\'ldos.dat0$a\' u 1:4 w filledcurves above y1=0 \,";
#         print AA "\'ldos.dat0$a\' u 1:6 w filledcurves above y1=0 \,";
#         print AA "\'ldos.dat0$a\' u 1:8 w filledcurves above y1=0 \,";
#         print AA "\'ldos.dat0$a\' u 1:20 w filledcurves above y1=0 lc rgb \"#339933\" title \'C \(Asite\)\' \,";
}



1: energy
2,3: s
4,5: py
6,7: pz
8,9: px
10,11: xy
12,13: yz
14,15: z2
16,17: zx
18,19: x2
20,21: tdos



#   egrid    s(up,dn)    y(up,dn)    z(up,dn)    x(up,dn)   xy(up,dn)   yz(up,dn)   z2(up,dn)   zx(up,dn)   x2(up,dn)    tdos(up,dn)    Is(up,dn)    Iy(up,dn)    Iz(up,dn)    Ix(up,dn)   Ixy(up,dn)   Iyz(up,dn)   Iz2(up,dn)   Izx(up,dn)   Ix2(up,dn)    id


7           ! number of layers
8 4 4 4 4 4 4 
49 50 51 52 53 54 55 56 57 58
=cut
