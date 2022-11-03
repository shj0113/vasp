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
#print "The composition condition is for last element\n";
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
print "num_atoms = @num_atoms2\n";
#print "$num_atoms2[-2]\n";

open(DOSCAR,"<DOSCAR") || die "cannot open DOSCAR, it read the E-fermi";
<DOSCAR> for (1 .. 5);
$line = <DOSCAR>;
$line =~ s/^\s+//g;
@temp = split(/\s+/,$line);
$E_fermi = $temp[3]; #Fermi level
#print $E_fermi;
close(DOSCAR);

open(PROCAR,"<PROCAR") || die "cannot open PROCAR";
<PROCAR>;
$line = <PROCAR>;
@temp = split(/\s+/,$line);
#print Dumper @temp;
$num_kpts = $temp[3];  #K-point 개수
$num_bands = $temp[7]; #Band 개수
$num_ions = $temp[11]; #전체 원자개수
print "ions error" unless $num_ions == (List::Util::sum @num_atoms);
unlink "band.dat";
#-------------------------------------------------------------------------------
# reading k-points, bands, weights  
#-------------------------------------------------------------------------------

my $cnt_kpts = 1, $cnt_bands =1, $cnt_ions=1;
my $kpoints_track=0;
$kpoint_before=pdl[0,0,0]; #PDL convert
<PROCAR>;

my @kpath=(); 
my @energies=();
#-------------------------------------------------------------------------------
#  upspin part
#-------------------------------------------------------------------------------
for (1 .. 2){
	$kpoints_track=0;
	$cnt_kpts=1;
	$cnt_bands=1;
	$kpoint_before=pdl[0,0,0]; #PDL convert
		while ($cnt_kpts <= $num_kpts) {
			$line = <PROCAR>;
			chomp($line);
			$line =~s/^\s+//;
			@temp = split(/\s+/,$line);
			$kpoint_now=pdl[$temp[3],$temp[4],$temp[5]]; #PDL convert

				$dk=$kpoint_now - $kpoint_before;
			$dkdk=sqrt(inner(($dk x $bvec),($dk x $bvec)));

			$kpoints_track += sclr($dkdk);
			$line=<PROCAR>;
			$cnt_bands=1;
			$kpoint_before = $kpoint_now->copy;
			while ($cnt_bands <= $num_bands) {
				$line=<PROCAR>;
				@temp = split(/\s+/,$line);
#push @eigenvalue, $temp[4];
				$eigenvalue = $temp[4] - $E_fermi;
				$line=<PROCAR>;
				$line=<PROCAR>;

				$cnt_ions = 1;
				while ($cnt_ions <=$num_ions) {
					$line=<PROCAR>;
					$line=~s/^\s+//;
					@temp=split(/\s+/,$line);
############################################################################
### insert the condition here
### $temp[0] = atom number $temp[10] = tot 
### $num_atoms2 = arrays for atmoic number considering elements
############################################################################
					push(@portion, $temp[10]) if $temp[0] > $num_atoms2[0];
#if ($temp[0] > 16) {
#	if ($temp[0] < 27) {
#push @portion,$temp[10];
#}
#if ($temp[0] > 27){
#	push @portion,$temp[10];
#}
#}
############################################################################ 
					$cnt_ions++; } $line=<PROCAR>; #tot
						@temp = split(/\s+/,$line);
					$tot = $temp[10];
					$composition = List::Util::sum @portion;
					$composition = $composition / $tot * 100 unless $tot==0;
					$composition = 100 if $composition > 100;
					$composition = 0 if $tot==0;
					@portion=();

					<PROCAR>;#blank_line
						push @kpath,$kpoints_track;
					push @band_num,$cnt_bands;
					push @energies,$eigenvalue;
					push @comp,$composition;
#	    printf EIGEN  "%f    %d    %f \n",sclr($kpoints_track),$cnt_bands,$eigenvalue;
					$cnt_bands++;
			}
			$cnt_kpts++;
			<PROCAR>;
		}
	$line = <PROCAR>;

	open(FF,">>band.dat");
	for $i (0 .. $num_bands-1) {
            print FF "#Band   $i\n";
		for $j (0 .. $num_kpts-1) {
			printf FF "%f  %f  %f\n",$kpath[$i+$j*$num_bands],$energies[$i+$j*$num_bands],$comp[$i+$j*$num_bands];
		}
		printf FF "\n";
	}
	close(FF);
#	print Dumper @kpath;

	push @kpath_tot, @kpath;
	push @energies_tot, @energies;
	push @comp_tot, @comp;

	undef @kpath;
	undef @energies;
	undef @comp;
	undef $kpoints_track;
}
#-------------------------------------------------------------------------------
#  down-spin part
#-------------------------------------------------------------------------------
=pod
open(FF,">>band.dat");
print FF "\n";
for $i (0 .. $num_bands-1) {
	for $j (0 .. $num_kpts-1) {
		printf FF "%f  %f  %f\n",$kpath[$i+$j*$num_bands],$energies[$i+$j*$num_bands],$comp[$i+$j*$num_bands];
	}
	printf FF "\n";
}
close(FF);
=cut

open(AA,"<band.dat");
$line=<AA>;
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
$yr1 = -5;
$yr2 = 9;
print GNU "set term pdf enhanced font 'Arial,12'\n";
print GNU "set output 'band.pdf'\n";
print GNU "set size ratio 1.5\n";
print GNU "set palette defined (0 'blue', 100 'red')\n";
#print GNU "set palette defined (0 'blue', 50 'red', 100 'dark-green')\n";
#print GNU "set palette defined (0 'blue', 50 'yellow' , 100 'dark-green')\n";
#print GNU "set ylabel 'E -E_f (eV)'\n";
print GNU "set yrange [$yr1 : $yr2]\n";
print GNU "set xrange [0 : $know]\n";
print GNU "set xtics ('{/Symbol G}' 0)\n";
my @xtics = ('{/Symbol G}','Y','F','L','Z','{/Symbol G}');
#my @xtics = ('{/Symbol G}','X','S','Y','{/Symbol G}','Z','U','R','T');
#my @xtics = ('{/Symbol G}','M','K','{/Symbol G}');
for ( my $i=1;$i<= $#boundary ; $i++ ) {
	print GNU "set arrow from $boundary[$i],$yr1 to $boundary[$i],$yr2 nohead\n";
	print GNU "set xtics add ('$xtics[$i]' $boundary[$i])\n";
#	print GNU "set xtics add ('{/Symbol M}' $boundary[$i])\n";
}
print GNU "set arrow from 0,0 to $boundary[-1],0 nohead lw 3 lt 'dashed'\n";
print GNU "set nocolorbox\n";
print GNU "plot 'band.dat' u 1:2 w l lc rgb 'red' lw 2 notitle\n";
print GNU "#plot 'band.dat' u 1:2:3 w l lc palette notitle\n";
close(GNU);
system("gnuplot band.gnu");
print "Data extracted successfully.\n";
print "Please check the panel boundary in 'band.gnu'\n";
system("evince band.pdf &");
