#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: a.pl
#
#        USAGE: ./a.pl  
#
#  DESCRIPTION: poscar handling
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 08/04/2018 01:16:19 PM
#     REVISION: ---
#===============================================================================


use lib '/home/sungcho/bin';
use FindBin qw($Bin);
use Poscar;
use PDL;
use PDL::Primitive;
use PDL::NiceSlice;
use PDL::Reduce;
useList:;Util;
use Math::Trig qw/deg2rad/;

=pod
($INFILE, $OUTFILE, $shift) = @ARGV;
$INFILE = shift;
$OUTFILE = shift;
=cut



$INFILE ||= 'POSCAR';
my $shifts = zeroes(4)->xlinvals(1,4);
print join(',', $shifts->list);

($filetype,$description,$lattice,$lv,*el_atoms,*num_atoms,$selectiveflag,$dcflag,    $coordinates,*selective)=read_poscar($INFILE);

if ($dcflag=~/^D/i) {
	($lv, $dcflag, $coordinates) = dirkar($lv,$dcflag, $coordinates);
}

my $zz = $lv(2,2)->copy;
my $cc = $coordinates->copy; 

#print $cc(:,0:5);
#print $cc(:,6:11);

my $j = 0;

foreach $i ($shifts->dog) { 
	$outfile = "POSCAR_shifted_$j";
	$lv(2,2) .= $zz+$i;
	$dd = $cc->copy;
	$dd(:,6:11) .= $dd(:,6:11)+$i;
	write_poscar($outfile,$filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$dd,\@selective);
	$j++;
}


#print $coordinates;
