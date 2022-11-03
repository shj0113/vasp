#!/usr/bin/perl
use lib '/home/csb444/lib';
use FindBin qw($Bin);
use Poscar;
use PDL;
use PDL::Primitive;
use PDL::NiceSlice;
use PDL::Reduce;
use List::Util;
use Math::Trig qw/deg2rad/;

($INFILE,$OUTFILE) = @ARGV;

$INFILE=shift;
$OUTFILE=shift;
#if($INFILE =~ /^\W/){$INFILE="POSCAR"}
$INFILE ||= 'POSCAR';
#defined $INFLIE ? 1 : "POSCAR";

($filetype,$description,$lattice,$lv,*el_atoms,*num_atoms,$selectiveflag,$dcflag,$coordinates,*selective)=read_poscar($INFILE);

if ($dcflag=~/^D/i) {
	($lv,$dcflag,$coordinates)=dirkar($lv,$dcflag,$coordinates);
}elsif ($dcflag=~/^C/i){
        ($lv,$dcflag,$coordinates)=kardir($lv,$dcflag,$coordinates);
}

if($OUTFILE =~ /^\w/){
	write_poscar($OUTFILE,$filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);
}else{
print_poscar($filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);
}
