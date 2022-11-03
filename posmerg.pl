#!/usr/bin/perl
#
use lib "/home/csb444/bin/";
use FindBin qw($Bin);
use Poscar;
use PDL;
use PDL::Primitive;
use PDL::NiceSlice;
use PDL::Reduce;
use List::Util;
use Math::Trig qw/deg2rad/;
#use diagnostics;
#use Poscar(read_poscar,write_poscar);

$INFILE1=shift;
$INFILE2=shift;
$OUTFILE=shift;

($filetype1,$description1,$lattice1,$lv1,*el_atoms1,*num_atoms1,$selectiveflag1,$dcflag1,$coordinates1,*selective1)=read_poscar($INFILE1);
($filetype2,$description2,$lattice2,$lv2,*el_atoms2,*num_atoms2,$selectiveflag2,$dcflag2,$coordinates2,*selective2)=read_poscar($INFILE2);

#print "$#selective1(@selective1)\n";
#print "$#selective2(@selective2)\n";

($filetype,$description,$lattice,$lv,*el_atoms,*num_atoms,$selectiveflag,$dcflag,$coordinates,*selective)=posmerg($filetype1,$filetype2,$description1,$description2,$lattice1,$lattice2,$lv1,$lv2,\@el_atoms1,\@el_atoms2,\@num_atoms1,\@num_atoms2,$selectiveflag1,$selectivefalg2,$dcflag1,$dcflag2,$coordinates1,$coordinates2,\@selective1,\@selective2);
$description = "merged pos";
#$lv = $lv1;

if($OUTFILE =~ /^\w/) {
	        write_poscar($OUTFILE,$filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);
}else{
	        print_poscar($filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);
}


#$a=sum($lv(0,:));
#$b=pdl [];
#$c=pdl[$a, 0, 0];
#$b=$b->glue(0,pdl [$a,0,0]);
#print $c;
#if ($dcflag=~'^d') {($lv,$dcflag,$coordinates)=dirkar($lv,$dcflag,$coordinates);}
#if ($dcflag=~'^c') {($lv,$dcflag,$coordinates)=kardir($lv,$dcflag,$coordinates);}

#rotate lv
#$lv=$lv x rotmat(30);
#print "$dcflag\n";
#$clv = pdl [[2, 0, 0],[0, 2, 0],[0, 0, 1.6]];
#($lv,$dcflag,$coordinates)=rotpos(60,$lv,$dcflag,$coordinates);

#($lv,*num_atoms,$coordinates,*selective)=poscarcp(2,2,1,$lv,\@num_atoms,$dcflag,$coordinates,\@selective);
##($lv,$dcflag,$coordinates)=adjlv($clv,$lv,$dcflag,$coordinates);

#write_poscar("output",$filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);

#sub rotmat{
#	my $angle=shift;
#	$angle=deg2rad($angle);
#	$rotmat= pdl [[cos($angle),-1*sin($angle),0],[sin($angle),cos($angle),0],[0,0,1]];
#	print $rotmat;
	#$lv[3]=$lv[3] x $rotmat;
#	return $rotmat;
#}
