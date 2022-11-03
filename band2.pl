#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: band.pl
#
#        USAGE: ./band.pl  
#
#  DESCRIPTION: VASP band structure plot using PROCAR
#  				can calculate spin-polarized and ionic contribution
#      OPTIONS: 
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 2014년 04월 07일 14시 15분 49초
#     REVISION: ---
#===============================================================================

use PDL;
use PDL::NiceSlice;
use PDL::AutoLoader;
use PDL::IO::Dumper;
use Data::Dumper;
use List::Util;
use Math::Trig qw/pi/;

#-------------------------------------------------------------------------------
#  reading parameters such as num_elements and so on...
#-------------------------------------------------------------------------------
open (OUTCAR,"<OUTCAR") || die "no outcar";
while($line=<OUTCAR>){
	if ($line=~/ISPIN/){
		$spin = (split /\s+/,$line)[3];
	}
}
#print $spin;


open (CONTCAR,"<CONTCAR") || die "cannot open CONTCAR, it reads the # of atoms";
#<CONTCAR> for (1 .. 5); #다섯줄 이동
$line=<CONTCAR>;
$scale=<CONTCAR>;
$a1=<CONTCAR>;
$a2=<CONTCAR>;
$a3=<CONTCAR>;

$a1=~s/^\s+//;
$a2=~s/^\s+//;
$a3=~s/^\s+//;
@avec1=split(/\s+/,$a1);
@avec2=split(/\s+/,$a2);
@avec3=split(/\s+/,$a3);
$a1 = pdl @avec1;
$a2 = pdl @avec2;
$a3 = pdl @avec3;

#construct lattice_vector & reciprocal vector
$avec = (pdl @avec1)->glue(1,pdl @avec2)->glue(1, pdl @avec3);
$b1 = 2*pi* crossp($a2, $a3) / (inner $a1, (crossp $a2, $a3));
$b2 = 2*pi* crossp($a3, $a1) / (inner $a2, (crossp $a3, $a1));
$b3 = 2*pi* crossp($a1, $a2) / (inner $a3, (crossp $a1, $a2));
$bvec = $b1->glue(1,$b2)->glue(1,$b3);

$line = <CONTCAR>;
$line =~ s/^\s+//g;
@el_atoms = split(/\s+/,$line); #원소 종류
$num_el = scalar @el_atoms; #원소 개수
#print "num_el = $num_el\n";
#print "@el_atoms\n";
$line = <CONTCAR>;
$line =~ s/^\s+//g;
@num_atoms = split(/\s+/,$line); #원자 개수
#print "@num_atoms\n";
close(CONTCAR);
$el_cnt = 0;
do {
	$tmp += $num_atoms[$el_cnt];
	push @num_atoms2,$tmp;
	$el_cnt++;
} while ( $el_cnt < $num_el );				# -----  end do-while  -----
#print "@num_atoms2\n";
#print "$num_atoms2[-2]\n";

open(DOSCAR,"<DOSCAR") || die "cannot open DOSCAR, it read the E-fermi";
<DOSCAR> for (1 .. 5);
$line = <DOSCAR>;
$line =~ s/^\s+//g;
@temp = split(/\s+/,$line);
$E_fermi = $temp[3]; #Fermi level
print "Fermilevel=$E_fermi\n";
close(DOSCAR);


open(EIGENVAL,"<EIGENVAL") || die "cannot open EIGENVAL";
<EIGENVAL>;
<EIGENVAL>;
<EIGENVAL>;
<EIGENVAL>;
<EIGENVAL>;
$line = <EIGENVAL>;
@temp = split /\s+/, $line;
$num_kpts = $temp[2]; #Kpoint 개수
$num_bands = $temp[3]; #Band 개수
#print "$num_kpts $num_bands \n";

my $cnt_kpts=1, $cnt_bands=1;
my $kpoints_track=0;
$kpoint_before=pdl[0,0,0];

<EIGENVAL>;

###################################
#now it begins
###################################

while ($cnt_kpts <= $num_kpts) {
	chomp($line = <EIGENVAL>);
	$line =~ s/^\s+//;
	@temp = split(/\s+/,$line);
	$kpoint_now = pdl[$temp[0],$temp[1],$temp[2]]; #PDL convert;
	$dk = $kpoint_now - $kpoint_before;
	$dkdk=sqrt(inner(($dk x $bvec),($dk x $bvec)));
	$kpoints_track += $dkdk;

	$cnt_bands=1;
	$kpoint_before = $kpoint_now->copy;
	while ($cnt_bands <= $num_bands) {
		$line = <EIGENVAL>;
		@temp = split(/\s+/,$line);
#		$temp[3] || print "This program is for spin-polarized system. Only majority spin is printed.";
		$eigen_up = $temp[2] - $E_fermi;
		$eigen_dn = $temp[3] - $E_fermi;
#		print Dumper @temp;
		push @kpath,sclr($kpoints_track);
		push @band_num,$cnt_bands;
		push @energy_up,$eigen_up;
		push @energy_dn,$eigen_dn;
		$cnt_bands++;
	}
	$cnt_kpts++;
	<EIGENVAL>;
}

open(FF,">band.dat");
for $i (0 .. $num_bands-1) {
	for $j (0 .. $num_kpts-1) {
		printf FF "%f  %f  %f\n",$kpath[$i+$j*$num_bands],$energy_up[$i+$j*$num_bands],$energy_dn[$i+$j*$num_bands];
	}
	printf FF "\n";
}
close(FF);

open(AA,"<band.dat");
for (my $i=0; $i<$num_kpts; $i++) {
	$line=<AA>;
	@temp = split(/\s+/,$line);
	$know = $temp[0];
	print "panel boundary = $know \n" if $know == $kbefore;
	push @boundary, $know if $know == $kbefore;
	push @panel_boundary,$know;
	$kbefore = $know;
}
print "panel boundary = $know \n";
push @boundary, $know;
close(AA);

open(GNU,">band.gnu");
$yr1 = -4;
$yr2 = 4;
print GNU "set term pdf enhanced font 'Arial,12'\n";
print GNU "set output 'band.pdf'\n";
print GNU "set size ratio 1.5\n";
print GNU "set ylabel 'E -E_f (eV)'\n";
print GNU "set yrange [$yr1 : $yr2]\n";
print GNU "set xrange [0 : $know]\n";
print GNU "set xtics ('{/Symbol G}' 0)\n";
print GNU "set key outside\n";
#my @xtics = ('{/Symbol G}','M','K','{/Symbol G}');
my @xtics = ('{/Symbol G}', 'L', 'B', 'Z' ,'{/Symbol G}', 'X', 'Q', 'F', 'P', 'Z', 'L', 'P');
for ( my $i=1;$i<= $#boundary ; $i++ ) {
	print GNU "set arrow from $boundary[$i],$yr1 to $boundary[$i],$yr2 nohead\n";
	print GNU "set xtics add ('$xtics[$i]' $boundary[$i])\n";
#   print GNU "set xtics add ('{/Symbol M}' $boundary[$i])\n";
}
if ($spin == 2) {
#print GNU "plot 'band.dat' u 1:2 w l title 'up', 'band.dat' u 1:3 w l title 'dn'\n";
print GNU "plot 'band.dat' u 1:2 w l ls 1 notitle, 'band.dat' u 1:3 w l ls 1 notitle\n";
#print GNU "plot 'band.dat' u 1:(\$2+\$3) w l notitle \n";
}elsif($spin ==1) {
print GNU "plot 'band.dat' u 1:2 w l notitle \n";
}
print GNU "#plot 'band.dat' u 1:2 w l ls 1 notitle, 'band.dat' u 1:3 w l ls 1 notitle\n";
close(GNU);
system("gnuplot band.gnu");
system("evince band.pdf");
print "Data extracted successfully.\n";
print "Please check the panel boundary in 'band.gnu'\n";
