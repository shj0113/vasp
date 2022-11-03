#!/usr/bin/env perl
#
use POSIX;
use FindBin qw($Bin);
use File::Copy;
=pod
use lib '/home/sungcho/bin/';
use Poscar;
use PDL;
use PDL::Primitive;
use PDL::NiceSlice;
use PDL::Reduce;
=cut
use List::Util;
use Math::Trig qw/deg2rad/;

for(1..5){
	$tmp=shift;
	push @rpt,$tmp if $tmp=~/^\d/;
	push @file,$tmp if $tmp =~/^[a-zA-Z]/;
}

$rpt[0]=1 if $rpt[0]==undef;
$rpt[1]=$rpt[0] if $rpt[1] == undef;
$rpt[2]=1 if $rpt[2] == undef;
#$file[0]='POSCAR' if $file[0] =~ /^w/;
$file[0] ||= 'POSCAR';
#print $file[0];


open(POS,"<$file[0]");
$line = <POS> for (1 .. 6);
chomp($line);
$line=~s/^\s+//;
@el_atoms = split(/\s+/,$line);
$line =<POS>;
$line=~s/^\s+//;
@num_atoms = split(/\s+/,$line);
$line=<POS>;

if ($line =~ /^S/i) {
	close(POS);
	copy($file[0],"$file[0].org.xbs");
	open(POS1,"<$file[0].org.xbs");
	@lines = <POS1>;
	close(POS1);
	open(POS2,">$file[0]");
	foreach $i (@lines) {
		print POS2 $i unless ($i =~/^S/i);
	}
	close(POS2);
		
}else{
	close(POS);
}


#($filetype,$description,$lattice,$lv,*el_atoms,*num_atoms,$selectiveflag,$dcflag,$coordinates,*selective)=read_poscar($file[0]);

#color define
$color[0] = "0.8 0.9 0.8";
$color[1] = "0.7 0 0";
$color[2] = "0.1 0.1 0.1";
$color[3] = "0.1 0.1 0.6";
$color[4] = "0.1 0.6 0.6";
$color[5] = "0.7 0.6 0.6";


open(ATOMS,">atoms.d");
print ATOMS "     $file[0] \n";
print ATOMS "     $rpt[0] $rpt[1] $rpt[2]   #nx,ny,nz \n";

#Automatic
for ($i=0;$i<@el_atoms;$i++) {
	$atomic_size = 1.5 - 0.3 * log($i+1);
	$atomic_size = floor($atomic_size*10)/10;
	#$atomic_size = 1.8 - 0.3*$i;
    print ATOMS "     $num_atoms[$i]  $el_atoms[$i]  $atomic_size  $color[$i]   # #ofatoms, atomic species, sphere size, color \n";
}

#Manual atomic_size
#@atomic_size=(1.5,1.0,1.5,1.0,1.0,0.5);
#for ($i=0;$i<@el_atoms;$i++) {
#    print ATOMS "     $num_atoms[$i]  $el_atoms[$i]  $atomic_size[$i]  $color[$i]   #        #ofatoms, atomic species, sphere size, color \n";
#}

print ATOMS "   0.03   0.5  0.5 0.5 #bond width, color\n "
