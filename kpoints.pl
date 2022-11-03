#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: kpoints.pl
#
#  DESCRIPTION: 
#
#       AUTHOR: Sung Beom Cho, csb444@hanyang.ac.kr
# ORGANIZATION: Hanyang University
#      VERSION: 1.0
#      CREATED: 2014년 07월 22일 12시 03분 34초
#===============================================================================

use File::Copy;
use 5.010;

for (1 .. 5) {
	$tmp = shift;
	$monk=$tmp if $tmp =~ /[a-zA-Z]/;
	push @rpt,$tmp if $tmp =~ /^\d/;
}
$monk ||= 'G';
#print "monk is $monk\n";

if ($rpt[1] == undef) {
	$rpt[1] = $rpt[0];
	$rpt[2] = $rpt[0];
}

if (-e "KPOINTS") {
	move ("KPOINTS","KPOINTS.bkup");
	print ("previous KPOINTS is backed up in KPOINTS.bkup\n");
}


open (KPOINTS,">KPOINTS");
print KPOINTS "generated from kpoints.pl\n";
print KPOINTS "0 \n";
print KPOINTS "$monk \n";
print KPOINTS "$rpt[0] $rpt[1] $rpt[2]\n";
print KPOINTS "0 0 0\n";
	


#print "(usage): kpoints.pl (option to add or substitude)\n";
#print "       : distinguish the options with the space \n";
#print "       : for band structure, I recommend it to write manually. \n";
#print "(example): kpoints.pl g 6 6 1 \n";

