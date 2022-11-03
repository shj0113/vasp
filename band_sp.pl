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
$line = <CONTCAR>;
$line =~ s/^\s+//g;
@num_atoms = split(/\s+/,$line); #원자 개수
close(CONTCAR);

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

#-------------------------------------------------------------------------------
# reading k-points, bands, weights  
#-------------------------------------------------------------------------------
open(EIGEN,">eigen.dat");

my $cnt_kpts = 1, $cnt_bands =1, $cnt_ions=1;
my $kpoints_track=0;
$kpoint_before=pdl[0,0,0]; #PDL convert
<PROCAR>;


#-------------------------------------------------------------------------------
#  upspin part
#-------------------------------------------------------------------------------
while ($cnt_kpts <= $num_kpts) {
	$line = <PROCAR>;
	chomp($line);
	$line =~s/^\s+//;
	@temp = split(/\s+/,$line);
	$kpoint_now=pdl[$temp[3],$temp[4],$temp[5]]; #PDL convert

	$dk=$kpoint_now - $kpoint_before;
	$dkdk=sqrt(inner(($dk x $bvec),($dk x $bvec)));

    $kpoints_track += $dkdk;
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
			#insert the condition here
#			push(@portion, $temp[10]) if $temp[0] == 6;
			$cnt_ions++;
		}
	    $line=<PROCAR>; #tot
	    @temp = split(/\s+/,$line);
	    $tot = $temp[10];
	    $composition = List::Util::sum @portion;
	    $composition = 0 if $tot ==0;
	    $composition = $composition / $tot * 100 unless $tot ==0;
	    @portion=();

		<PROCAR>;#blank_line
		push @kpath,sclr($kpoints_track);
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

open(FF,">band.up.dat");
for $i (0 .. $num_bands-1) {
	for $j (0 .. $num_kpts-1) {
		printf FF "%f  %f  %f\n",$kpath[$i+$j*$num_bands],$energies[$i+$j*$num_bands],$comp[$i+$j*$num_bands];
	}
	printf FF "\n";
}
close(FF);

@kpath_tot = @kpath;
@energies_tot = @energies;
@comp_tot = @comp;

#-------------------------------------------------------------------------------
#  down-spin part
#-------------------------------------------------------------------------------
while ($cnt_kpts <= $num_kpts) {
	$line = <PROCAR>;
	chomp($line);
	$line =~s/^\s+//;
	@temp = split(/\s+/,$line);
	$kpoint_now=pdl[$temp[3],$temp[4],$temp[5]]; #PDL convert

	$dk=$kpoint_now - $kpoint_before;
	$dkdk=sqrt(inner(($dk x $bvec),($dk x $bvec)));

    $kpoints_track += $dkdk;
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
			#insert the condition here
#			push(@portion, $temp[10]) if $temp[0] == 6;
			$cnt_ions++;
		}
	    $line=<PROCAR>; #tot
	    @temp = split(/\s+/,$line);
	    $tot = $temp[10];
	    $composition = List::Util::sum @portion;
	    $composition = $composition / $tot * 100 unless $tot ==0;
	    $composition = 0 if $tot ==0;
	    @portion=();

		<PROCAR>;#blank_line
		push @kpath,sclr($kpoints_track);
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


open(FF,">band.dn.dat");
for $i (0 .. $num_bands-1) {
	for $j (0 .. $num_kpts-1) {
		printf FF "%f  %f  %f\n",$kpath[$i+$j*$num_bands],$energies[$i+$j*$num_bands],$comp[$i+$j*$num_bands];
	}
	printf FF "\n";
}
close(FF);

push @kpath_tot,@kpath;
push @energies_tot,@energies;
push @comp_tot,@comp;

=pod
open(FF,">band.dat");
for $i (0 .. ($num_bands-1)) {
	for $j (0 .. ($num_kpts-1)) {
		printf FF "%f  %f  %f\n",$kpath[$i+$j*$num_bands],$energies[$i+$j*$num_bands],$comp[$i+$j*$num_bands];
	}
	printf FF "\n";
}
close(FF);
=cut


