#!/usr/bin/perl
use FindBin qw($Bin);
use Poscar;
use PDL;
use PDL::Primitive;
use PDL::NiceSlice;
use PDL::Reduce;
use List::Util;
use Math::Trig qw/deg2rad/;

$INFILE=shift;
$OUTFILE=shift;
if($INFILE != /^w/){$INFILE=POSCAR}

($filetype,$description,$lattice,$lv,*el_atoms,*num_atoms,$selectiveflag,$dcflag,$coordinates,*selective)=read_poscar($INFILE);

print "$lv\n";

if($OUTFILE =~ /^\w/){
	write_poscar($OUTFILE,$filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);
}else{
print_poscar($filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);
}
