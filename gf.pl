#!/usr/bin/perl
use List::Util qw/sum max/;
use Data::Dumper;

open(POSCAR,"<","POSCAR");
$line = <POSCAR> for (1 .. 7);
@num_eles = split(/\s+/,$line);
$num_atoms = sum @num_eles;
print "$num_atoms \n";

print "No. \t E0 \t\t force\n";
print "-------------------------------\n";
open(OUTCAR,"<OUTCAR");
$cnt=0;
while($line=<OUTCAR>){
	if ($line =~ /FORCES acting on ions/){
		$line=<OUTCAR>;
		$line=<OUTCAR> for (1 .. $num_atoms);
		$line=<OUTCAR>; # forces
		@tempforce=split/\s+/,$line;
		$ionforcex=($tempforce[1]+$tempforce[5]+$tempforce[7]+$tempforce[10])**2;
		$ionforcey=($tempforce[2]+$tempforce[5]+$tempforce[8]+$tempforce[11])**2;
		$ionforcez=($tempforce[5]+$tempforce[6]+$tempforce[9]+$tempforce[12])**2;
		$ionforce=sqrt( $ionforcex**2 + $ionforcey**2 + $ionforcez**2 );
		undef @tempforce;
		undef @atomic;
		undef $ionforcex;
		undef $ionforcey;
		undef $ionforcez;
	}


	if ($line =~ /POSITION/){
		  $line = <OUTCAR>;
		  for (1 .. $num_atoms) {
			   $line = <OUTCAR>;
			   chop($line);
			   @posforce=split(/\s+/,$line);
			   $atomic_force = sqrt($posforce[5]**2 + $posforce[5]**2 + $posforce[6]**2); 
			   push(@atomic,$atomic_force);
		  }
#		  $maxforce = sum @atomic;
		  $maxforce_before = $maxforce;
		  $maxforce = max @atomic;
		  undef @posforce;
		  undef @atomic;
#print "$cnt \t$maxforce \n";
	$cnt++;
	}
	if ($line =~ /energy  without entropy/){
		 undef @temp;
		 chomp($line);
		 @temp = split(/\s+/,$line);
#		  $cnt++;
		 #printf ("%d \t %.5f \t %.5f \t %.5f \n",$cnt,$temp[-1],abs($maxforce-$maxforce_before), $ionforce);
	printf ("%d \t %.5f \t %.5f \t %.5f \n",$cnt,$temp[-1],$maxforce, $ionforce);
		 }
	if ($line =~ /Elapsed time/){
print "-------------------------------\n";
#		 print "calculation finished\n";
		 $line =~ s/^\s+//;
		 print $line;
	}
}
