#!/usr/bin/env perl

use FindBin qw($Bin);
use lib '/home/sungcho/bin';
use Poscar;
use PDL;
use PDL::Primitive;
use PDL::NiceSlice;
use PDL::Reduce;
use List::Util;
use Math::Trig qw/deg2rad/;

for(1..5){
	$tmp=shift;
	push @rpt,$tmp if $tmp=~/^\d/;
	push @file,$tmp if $tmp =~/^[a-zA-Z]/;
}
$rpt[1]=$rpt[0] if $rpt[1] == undef;
$rpt[2]=1 if $rpt[2] == undef;
#$file[0]='POSCAR' if $file[0] =~ /^w/;
$file[0] ||= 'POSCAR';
#print $file[0];

($filetype,$description,$lattice,$lv,*el_atoms,*num_atoms,$selectiveflag,$dcflag,$coordinates,*selective)=read_poscar($file[0]);

($lv,*num_atoms,$coordinates,*selective)=poscarcp($rpt[0],$rpt[1],$rpt[2],$lv,\@num_atoms,$dcflag,$coordinates,\@selective);

if($file[1] =~ /^\w/) {
	write_poscar($file[1],$filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);
}else{
	print_poscar($filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);
}
