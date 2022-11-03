#!/usr/bin/perl
#
use FindBin qw($Bin);
use lib "$Bin";
use Poscar;
use PDL;
use PDL::Primitive;
use PDL::NiceSlice;
use PDL::Reduce;
use List::Util;
use Math::Trig qw/deg2rad/;
#use diagnostics;
#use Poscar(read_poscar,write_poscar);
#

$INFILE=shift;
$OUTFILE=shift;
$INFILE=POSCAR unless $INFILE =~ /^\w/;

($filetype,$description,$lattice,$lv,*el_atoms,*num_atoms,$selectiveflag,$dcflag,$coordinates,*selective)=read_poscar("$INFILE");

if($OUTFILE == undef){
	write_poscar($INFILE,$filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);
}else{
	print "OUTFILE =$OUTFILE\n";
	write_poscar($OUTFILE,$filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);
}

