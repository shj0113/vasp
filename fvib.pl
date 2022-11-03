#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: fvib.pl
#
#        USAGE: ./fvib.pl  
#
#  DESCRIPTION: calculating vibration contribution on free energy
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 01/29/2017 05:40:38 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use Data::Dumper;
use List::Util;

my $h = 4.135e-3;
my $kb = 8.617e-5;

my $T=shift @ARGV;
$T ||= 298.15;
#print($T);
my @vs;
my @temp;

open(my $outcar,"<","OUTCAR");
while(my $line=<$outcar>) {
    if ($line =~ /THz/) {
        unless($line =~ /f\/i/){
            @temp = split(/\s+/,$line);
            push @vs,$temp[4];
        }
    }
}

my $hv;
my @zpes;
my $ts_s;
my @ts_s;

for my $v (@vs) {
    $hv=$v*$h;
    push @zpes, $hv*0.5;
    $ts_s = $kb * $T * ($hv/$kb/$T/exp($hv/$kb/$T-1) -log(1-exp(-$hv/($kb*$T))));
    push @ts_s, $ts_s;
}

my $zpe = List::Util::sum(@zpes);
my $ts = List::Util::sum(@ts_s);
my $fvib = $zpe - $ts;
printf "ZPE = %.3f  eV\n",$zpe;
printf "Fvib = %.3f  eV\n",$fvib;
