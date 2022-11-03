#!/usr/bin/env perl
#version 1.01

package Poscar;
use Exporter;
@ISA = ('Exporter'); @EXPORT = ('read_poscar','write_poscar','dirkar','kardir','poscarcp','adjlv','rotpos','naming','rotmat','print_poscar','posmerg','pbcin','pbcout','cutline');
use strict;
#use warnings;
use PDL;
use PDL::Primitive;
use PDL::NiceSlice;
use PDL::Char;
use List::Util;
use List::MoreUtils;
use Data::Dumper;
use Math::Trig qw/deg2rad/;
#use diagnostics;

#variables
#description = description of poscar
#lattice = scale factor of poscar
#lv = lattice vector of poscar (pdl type)
#el_atoms = elements of atoms


#subroutine read_poscar
#
#use:
#($filetype,$description,$lattice,$lv,*el_atoms,*num_atoms,$selectiveflag,$dcflag,$coordinates,*selective)=read_poscar("POSCAR");

sub read_poscar{
	 my $filename = shift;
	 my @poscar = ();
	 my $description = "";
	 my $lattice = 0;
	 my @lv;
	 my $lv=pdl[];
	 my @el_atoms=();
	 my $el_atoms=pdl[];
	 my @num_atoms;
	 my $num_atoms=pdl[];
	 my $el_atoms=pdl[];
	 my $selectiveflag;
	 my $dcflag='d';
	 my $total_atoms;
	 my @coordinates;
	 my $coordinates=pdl[];
	 my @selective;
	 my $selective=pdl[];
	 my @line;
	 my $index;
	 my $i=0;
	 my $j=0;
	 my $filetype;
	 my $atomtypeflag;
	 my $line = " ";
	 my $cnt = 0;

	 open (IN,$filename) or die "In poscar.pm::read_poscar, cannot open $filename\n";
	 @poscar = <IN>;
	 close (IN);

	 chop($description = $poscar[0]);
	 chop($lattice = $poscar[1]);
	 $lattice =~ s/^\s+//;

#determine vasp4 or vasp5
	 $line = $poscar[5];
	 $line =~ s/^\s+//;
	 @line = split /\s+/,$line;
	 if ($line[0] =~ /^\d+$/) {
		  $filetype = "vasp4";
		  @el_atoms = ();
		  $index = 5;
	 } else {
		  $filetype = "vasp5";
		  $index = 6;
		  chomp($line = $poscar[$index-1]);
		  $line=~s/^\s+//;
		  @el_atoms = split(/\s+/,$line);
	 }

#read num_atoms

	 $line = $poscar[$index];
	 $line =~ s/^\s+//;
	 @num_atoms = split(/\s+/,$line);

# read basis

	 for ($i=0;$i<3;$i++) {
		  $line = $poscar[$i+2];
		  $line =~ s/^\s+//;
		  @line = split(/\s+/,$line);
		  $lv[$i] = pdl @line;
#             for ($j=0; $j<3; $j++) {$basis->[$j][$i] = $line[$j]*$lattice;}
	 }
	
#	 $lv[3] = $lv[0]->glue(1,$lv[1],$lv[2]);

	 $index += 1;
#read selective flag
	 $line = $poscar[$index];
	 $line =~ s/^\s+//;
	 if ($line =~/^s/i) {
		  chop($selectiveflag = $line);
		  $index += 2;
	 } else {
	 	 $selectiveflag='none';
	 	 $index +=1;
	 }
	 if ($poscar[$index-1] =~ /^c/i) {$dcflag='c';}

#read coordinates & selective

	 $total_atoms=List::Util::sum @num_atoms;
	 for($i=$index; $i<$index+$total_atoms; $i++) {
	 	  chomp($poscar[$i]);
		  $poscar[$i] =~ s/^\s+//;
		  @line = split(/\s+/,$poscar[$i]);
		  $coordinates[$i-$index] = pdl [$line[0], $line[1], $line[2]];
		  if ($selectiveflag=~/selective/i) {
			   $selective[$i-$index] = $line[3]." ".$line[4]." ".$line[5];
		  } else {
			   $selective[$i-$index] = " ";
		  }
	 }
	 for($i=0;$i<@num_atoms;$i++){
	 	 for($j=0;$j<$num_atoms[$i];$j++){
	 	 	 $line=$j+1;
	 	 	 $selective[$cnt] .=" ! $el_atoms[$i] $line";
	 	 	 $cnt++;
		 }
	 }
	
	$lv = cat @lv;
	$coordinates = cat @coordinates;
	 
	 return($filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);
}

#write_poscar
#use:
#("output",$filetype,$description,$lattice,$lv,\@el_atoms,\@num_atoms,$selectiveflag,$dcflag,$coordinates,\@selective);


sub write_poscar{
	 my $filename = shift;
	 my $filetype = shift;
	 my $description = shift;
	 my $lattice = shift;
	 my $lv = shift;
	 my $el_atoms = shift;
	 my $num_atoms = shift;
	 my $selectiveflag = shift;
	 my $dcflag = shift;
	 my $coordinates = shift;
	 my $selective = shift;

	 my $i = 0;
	 my $j = 0;
	 my @temp = ();
	 my $total_atoms;
	 my @line=();
	 my $line=" ";
	 my @lv =();
	 my @num_atoms=();
	 my @coordinates;
	 my @selective=();

	 open (OUT,">",$filename) or die "In Poscar.pm::write_poscar, cannot open $filename\n";
	 print OUT $description,"\n";
	 print OUT "   $lattice \n";
	 @lv = dog $lv;
	 for ($i=0; $i<3; $i++) {
		  @temp = list($lv[$i]);
		  printf OUT "   %21.16f %21.16f %21.16f\n", ($temp[0],$temp[1],$temp[2]);
	 }
	 if ($filetype =~ /vasp5/){print OUT "  @$el_atoms\n";}
	 print OUT "  @$num_atoms\n";
	 if ($selectiveflag =~ /selective/i){print OUT "$selectiveflag\n";}
	 $dcflag =~ s/^\s+//;
	 if ($dcflag =~ /^c/i){
	 	 $dcflag='Cartesian';
	 }else{
	 	 $dcflag='Direct';
	 }
	 print OUT "$dcflag\n";
	 $total_atoms=List::Util::sum @$num_atoms;
	 @coordinates = dog $coordinates;
	 for ($i=0;$i<$total_atoms;$i++){
	 	 @line=list($coordinates[$i]);
	 	 for ($j=0; $j<3; $j++) {	 	 	
	 	 	 if ($dcflag=~/^d/i ){
#	 	 	 	 $line[$j] -= 1 while $line[$j]>=1;
#	 	 	 	 $line[$j] += 1 while $line[$j]<0;
			 }
			 printf OUT "%20.16f", $line[$j]."   ";
		 }
		 print OUT " ".$$selective[$i]."\n";
	 }
	 close(OUT);
	 return();
}

sub print_poscar{
	 my $filetype = shift;
	 my $description = shift;
	 my $lattice = shift;
	 my $lv = shift;
	 my $el_atoms = shift;
	 my $num_atoms = shift;
	 my $selectiveflag = shift;
	 my $dcflag = shift;
	 my $coordinates = shift;
	 my $selective = shift;

	 my $i = 0;
	 my $j = 0;
	 my @temp = ();
	 my $total_atoms;
	 my @line=();
	 my $line=" ";
	 my @lv =();
	 my @num_atoms=();
	 my @coordinates;
	 my @selective=();
	
#	 open (OUT,">",$filename) or die "In Poscar.pm::write_poscar, cannot open $filename\n";
	 print STDOUT $description,"\n";
	 print STDOUT "   $lattice \n";
	 @lv = dog $lv;
	 for ($i=0; $i<3; $i++) {
		  @temp = list($lv[$i]);
		  printf STDOUT "   %21.16f %21.16f %21.16f\n", ($temp[0],$temp[1],$temp[2]);
	 }
	 if ($filetype =~ /vasp5/) {
	 	 print STDOUT "  @$el_atoms\n";
	 }
	 print STDOUT "  @$num_atoms\n";
	 if ($selectiveflag =~ /selective/i){print STDOUT "$selectiveflag\n";}
	 $dcflag=~s/\s+//;
	 if ($dcflag=~/^c/){
	 	 $dcflag='Cartesian';
	 }else{
	 	 $dcflag='Direct';
	 }
	 print STDOUT "$dcflag\n";
	 $total_atoms=List::Util::sum @$num_atoms;
	 @coordinates = dog $coordinates;
	 for ($i=0;$i<$total_atoms;$i++){
#	 	 print $coordinates[$i];
	 	 @line=list($coordinates[$i]);
#	 	 print @line;
	 	 for ($j=0; $j<3; $j++) {	 	 	
	 	 	 if ($dcflag=~/^d/i ){
	 	 	 	 $line[$j] -= 1 while $line[$j]>=1;
	 	 	 	 $line[$j] += 1 while $line[$j]<0;
			 }
			 printf STDOUT "%20.16f", $line[$j]."   ";
		 }
		 print STDOUT " ".$$selective[$i]."\n";
	 }
#	 close(OUT);
	 return();
}


#dirkar (direct to cartesian)
#
#($lv,$dcflag,$coordinates)=dirkar($lv,$dcflag,$coordinates);

sub dirkar {
	my $lv=shift;
	my $dcflag=shift;
	my $coordinates=shift;
	
	if ($dcflag =~/^d/i) {
		$coordinates= $coordinates x $lv;
		$dcflag = 'c';
	}
	return($lv,$dcflag,$coordinates);
}


#kardir (cartesian to direct)
#($lv,$dcflag,$coordinates)=kardir($lv,$dcflag,$coordinates);
sub kardir{
	my $lv=shift;
	my $dcflag=shift;
	my $coordinates=shift;
	
	if ($dcflag =~/^c/i) {
		$coordinates= $coordinates x $lv->inv;
		$dcflag = 'd';
	}
	return($lv,$dcflag,$coordinates);

}


#poscarcp (copying poscar [n]x[n]x[n] )
#($lv,*num_atoms,$coordinates,*selective)=poscarcp(2,2,1,$lv,\@num_atoms,$dcflag,$coordinates,\@selective);

sub poscarcp{
	my @a;
	 $a[0]=shift;
	 $a[1]=shift;
	 $a[2]=shift;
	my $lv=shift;
	my $num_atoms=shift;
	my $dcflag=shift;
	my $coordinates=shift;
	my $selective=shift;
	my $temp_dc=$dcflag;
	my $temp;
	my @temp;
	my @coord;
	my $ncoord;
	my @ncoord;
	my $ncoordinates;
	my @b;
	my $total_atoms;
	my @num_atoms=@$num_atoms;
	my @num_atoms1;
	my $i;
	my $j;
	my $k;
	my @nselective;
	my $loop=0;
	my @loopindex;
	
	if($dcflag=~/^c/i){
		($lv,$dcflag,$coordinates)=kardir($lv,$dcflag,$coordinates);
	}
	$lv=$lv*pdl[[$a[0],$a[0],$a[0]],[$a[1],$a[1],$a[1]],[$a[2],$a[2],$a[2]]];
	$temp=pdl @num_atoms;
	$temp *= $a[0]*$a[1]*$a[2];
	$total_atoms=sum $temp;
	@temp = dog $coordinates;

#generates integrated num_atoms
	for($i=0;$i<@num_atoms;$i++){
		for($j=0;$j<=$i;$j++){
			$num_atoms1[$i]+=$num_atoms[$j];
			#print $i;
		}
	}
	unshift @num_atoms1,'0';
#set num_atoms
	@num_atoms=list($temp);
#generates repeat of coordinates
	for($k=0;$k<@num_atoms1;$k++){
		$loop=0;
		for($b[2]=0;$b[2]<$a[2];$b[2]++){
			for($b[1]=0;$b[1]<$a[1];$b[1]++){
				for($b[0]=0;$b[0]<$a[0];$b[0]++){
					for($i=$num_atoms1[$k];$i<$num_atoms1[$k+1];$i++){
						@coord=list($temp[$i]);
						for($j=0;$j<3;$j++){
							if($coord[$j]>1){$coord[$j]-=1;}
							elsif($coord[$j]<0){$coord[$j]+=1;}
							$coord[$j]=($coord[$j]+$b[$j])/$a[$j];
						}
							$ncoord=pdl @coord;
							push @ncoord, $ncoord;
#							$$selective[$i]=$$selective[$i]."+";
							push @loopindex,"$b[0]-$b[1]-$b[2]";
							push @nselective,$$selective[$i];
					}
				}
			}
		}
	}
	$ncoordinates = pdl @ncoord;
	for($i=0;$i<$total_atoms;$i++){
#		$nselective[$i]=$nselective[$i]." loop ".$loopindex[0]."-".$loopindex[1]."-".$loopindex[2];
		$nselective[$i]=$nselective[$i]."   ($loopindex[$i])";
	}

	if($temp_dc=~/^c/i){($lv,$dcflag,$ncoordinates)=dirkar($lv,$dcflag,$ncoordinates);}
	return ($lv,\@num_atoms,$ncoordinates,\@nselective);
}

#adjlv
#adjust lattice vector
#($lv,$dcflag,$coordinates)=adjlv($clv,$lv,$dcflag,$coordinates);

sub adjlv{
	my $clv= shift; #clv should be 3x3 pdl structure
	my $lv = shift;
	my $dcflag = shift;
	my $coordinates = shift;

	if ($dcflag=~/^d/i){
		($lv,$dcflag,$coordinates)=dirkar($lv,$dcflag,$coordinates);
		($lv,$dcflag,$coordinates)=kardir($clv,$dcflag,$coordinates);
	}elsif ($dcflag=~/^c/i){
		$lv=$clv;
	}
	return($lv,$dcflag,$coordinates);
}

#rotpos
#($lv,$dcflag,$coordinates)=rotpos(90,$lv,$dcflag,$coordinates);

sub rotpos{
	my $angle=shift;
	my $lv=shift;
	my $dcflag=shift;
	my $coordinates=shift;

	if ($dcflag=~/^d/i){
		$lv = $lv x rotmat($angle);
	}elsif($dcflag=~/^c/i){
		($lv,$dcflag,$coordinates)=kardir($lv,$dcflag,$coordinates);
		$lv=$lv x rotmat($angle);
		($lv,$dcflag,$coordinates)=dirkar($lv,$dcflag,$coordinates);
	}
	return ($lv,$dcflag,$coordinates);
}

#sub tslpos
#sub pbcin
#sub pbcout

#naming
#(*el_atoms,*num_atoms,*selective)=naming(\@el_atoms,\@num_atoms,\@selective);
sub naming{
	my $el_atoms=shift;
	my @el_atoms=@$el_atoms;
	my $num_atoms=shift;
	my @num_atoms=@$num_atoms;
	my $selective=shift;
	my @selective=@$selective;
	my $cnt=0;
	my $i;
	my $j;
	my $line;

	for($i=0;$i<@num_atoms;$i++){
		for($j=0;$j<$num_atoms[$i];$j++){
			$line=$j+1;
			#$selective =~ /(\s+)(\w)(\s+)(\w)(\s+)(\w)/
			$selective[$cnt] =~ /(T|F) (T|F) (T|F)/;
			#$selective[$cnt] .=" ! $el_atoms[$i] $line";
			$selective[$cnt] =" $1 $2 $3 ! $el_atoms[$i] $line";
			$cnt++;
		}
	}

	return(\@el_atoms,\@num_atoms,\@selective);
}


sub rotmat{
	my $angle=shift;
	my $rotmat;
        $angle=deg2rad($angle);
        $rotmat= pdl [[cos($angle),-1*sin($angle),0],[sin($angle),cos($angle),0],[0,0,1]];
        return $rotmat;
}

sub rotmat2{
	my $ux=shift;
	my $uy=shift;
	my $uz=shift;
	my $angle=shift;
	my $rotmat2;
        $angle=deg2rad($angle);
        $rotmat2= pdl [[cos($angle)+$ux**2*(1-cos($angle)),$ux*$uy(1-cos($angle))-$uz*sin($angle),$ux*$uz*(1-cos($angle))],[$uy*$ux*(1-cos($angle))+$uz*sin($angle),cos($angle)+$uy**2*(1-cos($angle)),$uy*$uz*(1-cos($angle))-$ux*sin($angle)],[$uz*$ux*(1-cos($angle))-$uy*sin($angle),$uz*$uy*(1-cos($angle))+$ux*sin($angle),cos($angle)+$uz**2*(1-cos($angle))]];
        return $rotmat2;
}

#posmerg (summing poscar)
#()=posmerg{$description1,$description2,$lattice1,$lattice2,$lv1,$lv2,$selectiveflag1,$selectiveflag2, 
#($nfiletype,$ndescription,$nlattice,$nlv,*nel_atoms,*nnum_atoms,$nselectiveflag,$ndcflag,$ncoordinates,*nselective)=posmerg($filetype1,$filetype2,$description1,$description2,$lattice1,$lattice2,$lv1,$lv2,\@el_atoms1,\@el_atoms2,\@num_atoms1,\@num_atoms2,$selectiveflag1,$selectivefalg2,$dcflag1,$dcflag2,$coordinates1,$coordinates2,\@selective1,\@selective2);

sub posmerg{
	my $filetype1=shift;
	my $filetype2=shift;
	my $description1=shift;
	my $description2=shift;
	my $lattice1=shift;
	my $lattice2=shift;
	my $lv1=shift;
	my $lv2=shift;
	my $el_atoms1=shift;
	my $el_atoms2=shift;
	my $num_atoms1=shift;
	my $num_atoms2=shift;
	my $selectiveflag1=shift;
	my $selectiveflag2=shift;
	my $dcflag1=shift;
	my $dcflag2=shift;
	my $coordinates1=shift;
	my $coordinates2=shift;
	my $selective1=shift;
	my $selective2=shift;
	my $a;
	my $b;
	my $i;
	my $j;
	my $k;
	my $nfiletype;
	my $ndescription;
	my $nlattice;
	my $nlv=pdl[];
	my @nel_atoms;
	my @nnum_atoms;
	my $nselectiveflag;
	my $ndcflag;
	my $ncoordinates;
	my @nselective=();

	if($filetype1==$filetype2){
		$nfiletype=$filetype1;
	}else{
		$nfiletype='vasp4';
	}
	
	$ndescription = $description1." + ".$description2;

	if ($lattice1==$lattice2){
		$nlattice=$lattice1;
	}else{
		$lv1*=$lattice1;
		$lv2*=$lattice2;
		$nlattice=1;
	}

	if ($lv1(0,0) == $lv2(0,0)) {
		$k=0;
		for $i (0..2) {
			for $j (0..2){
				if($lv1($i,$j)==$lv2($i,$j)){
					$k++;
				}
			}
		}
		if($k==9) {
			$nlv=$lv1;
		}
	}else{
		($lv1,$dcflag1,$coordinates1)=dirkar($lv1,$dcflag1,$coordinates1);
		($lv2,$dcflag2,$coordinates2)=dirkar($lv2,$dcflag2,$coordinates2);
		#$a=sum($lv1(0,:));
		#$b=sum($lv2(0,:));
		#if ($a>$b) {
		#	$nlv=$nlv->glue(0,pdl [$a,0,0]);
		#}else{
		#	$nlv=$nlv->glue(0,pdl [$b,0,0]);
		#}
		#$a=sum($lv1(1,:));
		#$b=sum($lv2(1,:));
		#if ($a>$b) {
		#	$nlv=$nlv->glue(1,pdl [0,$a,0]);
		#}else{
		#	$nlv=$nlv->glue(1,pdl [0,$b,0]);
		#}
		#$a=sum($lv1(2,:));
		#$b=sum($lv2(2,:));
		#if ($a>$b) {
		#	$nlv=$nlv->glue(1,pdl [0,0,$a]);
		#}else{
		#	$nlv=$nlv->glue(1,pdl [0,0,$b]);
		#}
		if($lv1->abs->sum>$lv2->abs->sum){
			$nlv=$lv1;
		}else{
			$nlv=$lv2;
		}
		print STDOUT "Check out the lattice vector and adjlv it!\n";
	}

	push @nel_atoms,@$el_atoms1,@$el_atoms2;
	push @nnum_atoms,@$num_atoms1,@$num_atoms2;

	if(($selectiveflag1=~/^selective/i)&&($selectiveflag2=~/^selective/i)){
		$nselectiveflag="Selective Dynamics";
		push  @nselective,@$selective1,@$selective2;

	}else{
		$nselectiveflag="none";
		for $a (0..$#$selective1) {
			$$selective1[$a] =~ s/T|F//g;
			$$selective1[$a] =~ s/\s+$//g;
		}
		for $b (0..$#$selective2) {
			$$selective2[$b] =~ s/T|F//g;
			$$selective2[$a] =~ s/\s+$//g;
		}
		push @nselective,@$selective1,@$selective2;
#		print "$nselective[2]-end\n";
		(*nel_atoms,*nnum_atoms,*nselective)=naming(\@nel_atoms,\@nnum_atoms,\@nselective);
	}
	#if $lv1==$lv2 ~> Dir or Cart., $lv1!=$lv2 ~> Cart.
	if (($dcflag1=~/^c/i)&&($dcflag2=~/^c/i)){
			$ndcflag='c';
	}elsif(($dcflag1=~/^c/i)&&($dcflag2=~/^c/i)){
			$ndcflag='d';
	}else{
		($lv1,$dcflag1,$coordinates1)=dirkar($lv1,$dcflag1,$coordinates1);
		($lv2,$dcflag2,$coordinates2)=dirkar($lv2,$dcflag2,$coordinates2);
		$ndcflag='c';
	}

	$ncoordinates=$coordinates1->glue(1,$coordinates2);
	
	return($nfiletype,$ndescription,$nlattice,$nlv,\@nel_atoms,\@nnum_atoms,$nselectiveflag,$ndcflag,$ncoordinates,\@nselective);
}

#pbcin
#($lv,$dcflag,$coordinates)=cutpbc($lv,$dcflag,$coordinates)

sub pbcin{
	my $lv=shift;
	my $dcflag=shift;
	my $coordinates=shift;
	my $odcflag=$dcflag;
	my @line;
	my @line2;
	my $i;
	my $j;
	my @coordinates;

	($lv,$dcflag,$coordinates)=kardir($lv,$dcflag,$coordinates);
	 @coordinates = dog $coordinates;
	 for ($i=0;$i<@coordinates;$i++){
	 	 @line=list($coordinates[$i]);
	 	 @line2=();
	 	 for ($j=0; $j<3; $j++) {	 	 	
	 	 	 $line[$j] -= 1 while $line[$j]>=1;
	 	 	 $line[$j] += 1 while $line[$j]<0;
	 	 	 push @line2,$line[$j];
		 }
		 $coordinates[$i]=pdl @line2;
	}
	$coordinates = cat @coordinates;

	return ($lv,$dcflag,$coordinates);
}

#pbcout
#($lv,*num_atoms,$dcflag,$coordinates)=cutpbc($lv,\@num_atoms,$dcflag,$coordinates)
#num_atoms를 받아와야함.

sub pbcout{
	my $lv=shift;
	my $num_atoms=shift;
	my @num_atoms1=();
	my @num_atoms2=();
	my $dcflag=shift;
	my $coordinates=shift;
	my $odcflag=$dcflag;
	my @line;
	my @line2;
	my $i;
	my $j;
	my @coordinates;
	my @ncoordinates;
	my $cnt++;
	my $k;
    
    #generates integrated num_atoms
	for($i=0;$i<@$num_atoms;$i++){
		for($j=0;$j<=$i;$j++){
			$num_atoms1[$i]+=$$num_atoms[$j];
		}
	}
	unshift @num_atoms1,'0';

   	($lv,$dcflag,$coordinates)=kardir($lv,$dcflag,$coordinates);
   	@coordinates = dog $coordinates;
   	for ($k=0;$k<$#num_atoms1;$k++){
   			$cnt=0;
   			for ($i=$num_atoms1[$k];$i<$num_atoms1[$k+1];$i++){
	 	 		@line=list($coordinates[$i]);
	 	 		 	if (List::MoreUtils::all {($_>=0) && ($_<=1)} @line){
	 	 		 		 push @ncoordinates,pdl @line;
	 	 		 		 $cnt++;
				 	}
		 	}
			push @num_atoms2, $cnt;
	}
	$coordinates = pdl @ncoordinates;
	if ($odcflag=~/^c/i){
   	($lv,$dcflag,$coordinates)=dirkar($lv,$dcflag,$coordinates);
	}

	return ($lv,\@num_atoms2,$dcflag,$coordinates);
}

#($lv,*num_atoms,$dcflag,$coordinates)=cutline([ul],a,b,$lv,\@num_atoms,$dcflag,$coordinates)
#num_atoms를 받아와야함.
sub cutline{
		my $uplow=shift;
		if ($uplow != /^[ul]/i) { die "cutline function requires [upper/lower]&ax+b arguments!\n ax+b should be in 'direct coordinate'"}
		my $a=shift;
		my $b=shift;
		my $lv=shift;
		my $num_atoms=shift;
		my @num_atoms1=();
		my @num_atoms2=();
		my $dcflag=shift;
		my $coordinates=shift;
		my @coordinates;
		my @ncoordinates;
		my $line;
		my $i;
		my $j;
		my $k;
		my @line;
		my $cnt;
	
		#generates integrated num_atoms
		for($i=0;$i<@$num_atoms;$i++){
		for($j=0;$j<=$i;$j++){
				$num_atoms1[$i]+=$$num_atoms[$j];
				}
		}
		unshift @num_atoms1,'0';
		
		($lv,$dcflag,$coordinates)=kardir($lv,$dcflag,$coordinates);
		@coordinates = dog $coordinates;
		for ($k=0;$k<$#num_atoms1;$k++){
				$cnt=0;
				for ($i=$num_atoms1[$k];$i<$num_atoms1[$k+1];$i++){
						@line=list($coordinates[$i]);
						if ($uplow =~/^u/i) {
								if ($line[1]>$a*$line[0]+$b){
										push @ncoordinates,pdl @line;
										$cnt++;
								}
						}elsif ($uplow =~/^l/i) {
								if ($line[1]<$a*$line[0]+$b){
										push @ncoordinates,pdl @line;
										$cnt++;
								}
						}
				}
				push @num_atoms2, $cnt;
		}

		$coordinates = pdl @ncoordinates;
		return ($lv,\@num_atoms2,$dcflag,$coordinates);
}
						
1;
