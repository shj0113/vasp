#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: scissor.pl
#
#        USAGE: ./scissor.pl  
#
#  DESCRIPTION: scissor-like operator
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 08/13/18 11:14:36
#     REVISION: ---
#===============================================================================

#use strict;
#use warnings;
#use utf8;


my $scissor = $ARGV[0];
my $cbm = $ARGV[1];
open(BAND,"<BAND.dat");
#open(BAND,"<band.dat");
open(OUT,">BAND2.dat");

our $cnt=0;

while (my $line = <BAND>) {
    if ($line =~ /Band/) {
        $cnt++;
        print OUT "\n";
    }
    print OUT $line;
    last if ($cnt == $cbm);
}

our @temp;

while (my $line =<BAND>) {
    if ($line =~ /Band/) {
        $cnt++;
        print OUT "\n";
        print OUT $line;
    }elsif ($line =~/^\n$/){
        print OUT $line;
    }else{
        @temp = split (/\s+/,$line);
        $s_up = $temp[2]+$scissor;
        $s_dn = $temp[3]+$scissor;
        print OUT "    $temp[1]   $s_up    $s_dn\n";
    }
}


close(BAND);
close(OUT);
