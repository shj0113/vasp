#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: integration.pl
#
#  DESCRIPTION: 
#
#       AUTHOR: Sung Beom Cho, csb444@hanyang.ac.kr
# ORGANIZATION: Hanyang University
#      VERSION: 1.0
#      CREATED: 2014년 06월 27일 15시 11분 17초
#===============================================================================
use Modern::Perl;
use PDL;
use PDL::GSL::INTERP;

my $file = $ARGV[0];
$file ||= "CLINE";
open(my $cline,"<",$file) or die ("cannot read CLINE");
my @fields;
my (@z, @rho);
while (my $line=<$cline>) {
	@fields = split /\s+/, $line;
	push @z, $fields[0];
	push @rho, $fields[1];
}
close($cline);

open (my $pos, "<", 'CONTCAR') or die ("cannot read CONTCAR");
<$pos>;
my $scale = <$pos>;
#print $scale;
my $lv1 = <$pos>;
$lv1 = pdl $lv1;
my $lv2 = <$pos>;
$lv2= pdl $lv1;
my $area = ($lv1 x $lv2->transpose)/2 ;
$area = 5.264251031;
$area = 4.9309769822723597 * 4.2703513321241999;
say "area = $area";


my $z = pdl @z;
my $rho = pdl @rho;
$a = $z * $rho;
my $spl = PDL::GSL::INTERP->init('cspline',$z,$a);
my ($res,$i);
$res = $spl->integ(0,$z[-1]);
my $epsilon = 8.854*10**-12 /10**10 /1.6/10**-19;
$epsilon = -180.92;
say "dipole = $res eA";
my $potential= $res * $epsilon / $area;
say "potential = $potential eV";
