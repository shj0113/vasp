#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: phonon.pl
#
#        USAGE: ./phonon.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: YOUR NAME (), 
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 02/22/2017 01:43:45 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

use File::Copy "cp";

my @num=glob('POSCAR-*');
@num = map {s/^POSCAR-//; $_;} @num;
my $cnt=scalar(@num);
my $incar='INCAR';
my @data;
my @new_data;



for my $i  (@num) {
    mkdir "disp-$i";
    cp('INCAR',"disp-$i");
    cp('KPOINTS', "disp-$i");
    cp('POTCAR', "disp-$i");
    cp("POSCAR-$i", "disp-$i/POSCAR");
    chdir "disp-$i";

    open (FILE,'<',$incar);
    @data=<FILE>;
    for my $j (@data) {
        $j=~s/.*/NSW = 0/ if $j=~/NSW/;
        $j=~s/.*/IBRION = -1/ if $j=~/IBRION/;
        $j=~s/.*// if $j=~/MAGMOM/;
        $j=~s/.*/EDIFF=1.0E-08/ if $j=~/EDIFF / || $j=~/EDIFF=/;
        $j=~s/.*/NPAR=4/ if $j=~/NPAR/;
        $j=~s/.*/ALGO=Normal/ if $j=~/ALGO/;
        #$j=~s/.*/EDIFFG=1.0E-08/ if $j=~/EDIFFG / || /EDIFFG=/;
        push @new_data, $j;
    }
    close(FILE);

    open(FILE,'>',$incar);
    for my $j (@new_data) {
        print FILE $j;
    }

    #system("pbs.pl 2");
    #system("sbatch runjob");
    
    chdir "..";
	$#data = -1;
	$#new_data = -1;
}



=pod
sub read_file {
    my ($filename) = @_;
 
    open my $in, '<:encoding(UTF-8)', $filename or die "Could not open '$filename' for reading $!";
    local $/ = undef;
    my $all = <$in>;
    close $in;
 
    return $all;
}
 
sub write_file {
    my ($filename, $content) = @_;
 
    open my $out, '>:encoding(UTF-8)', $filename or die "Could not open '$filename' for writing $!";;
    print $out $content;
    close $out;
 
    return;
}
=cut
