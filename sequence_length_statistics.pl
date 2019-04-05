#!/usr/bin/perl -w

use strict;
use Math::NumberCruncher;

if(@ARGV != 1) {
    die "Usage: $0 <fasta_file>\n";
}

my $sequence = "";
my $length = 0;
my $total_length = 0;
my $total_reads = 0;
my $name = "";
my $aux = "";
my @aseqsize = ();
while(<>) {
    
    if(/>(\S+)\s+/) {
        $name = "$1";
	$total_reads++;
    }
    if(!(/>/og)) {
        chop;
        $sequence .= "$_";
    }elsif((/>/) && ($aux)) {
       $length = length($sequence);
	$total_length += $length;
	push @aseqsize, $length;
        $sequence = "";
        $length = 0;
    }
    $aux = $name;
}

my $average  = Math::NumberCruncher::Median(\@aseqsize);
my $identity = Math::NumberCruncher::Mean(\@aseqsize);
my $StdDev   = Math::NumberCruncher::StandardDeviation(\@aseqsize,3);
my ($high, $low) = Math::NumberCruncher::Range(\@aseqsize);

printf "Contig/Read Average size: %3.2f ($total_length/$total_reads)\n",($total_length/$total_reads);
printf "Contig/Read Median size : %3.2f\n", $average;
printf "Contig/Read size Standard deviation : %3.2f\n", $StdDev;
printf "[Minimum, Maximun] sizes : [%3.2f,%3.2f]\n", $low, $high;
