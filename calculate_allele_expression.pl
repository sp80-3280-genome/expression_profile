#!/usr/bin/perl -w

use strict;
use Statistics::PointEstimation;
use Math::NumberCruncher;
use vars qw(%hsamples);

if(@ARGV != 6) {
    die "Usage: $0 <SampleName_1> <file_Sample_1> <SampleName_2> <file_Sample_2> <SampleName_3> <file_Sample_3>\n";
}

my $t1 = shift;
my $f1 = shift;
my $t2 = shift;
my $f2 = shift;
my $t3 = shift;
my $f3 = shift;

my %hsum     = ();
my $talleles = 0;
my $tallelesexp = 0;
my $average  = 0;
my @ameant   = ();
my @aexp     = ();
my $CIMin    = 0;
my $CIMax    = 0;
my $concat   = "";
my $next     = 0;
my $mean     = 0;

%hsamples = ();

readfile($f1,$t1);
readfile($f2,$t2);
readfile($f3,$t3);

#Summarize
my $stat = new Statistics::PointEstimation;
$stat->set_significance(95); #set the significance(confidence) level to 95%

print "TotalAlleles\tLeafAlleles\tLeafAlleleExp\tInternode1Alleles\tInternode1AlleleExp\tInternode5Allele\tInternode5AlleleExp\tAverageExp\tCIMin\tCIMax\n";
foreach my $g (sort keys %hsamples) {
    $next = 0;
    foreach my $t (sort keys %{$hsamples{$g}}) {
	$talleles = keys %{$hsamples{$g}{$t}};
	
	foreach my $al (sort keys %{$hsamples{$g}{$t}}) {
	    push @aexp, $hsamples{$g}{$t}{$al};
	}
	for my $i (0..scalar(@aexp)-1) {		
	    $tallelesexp++ if($aexp[$i]);
	}	
	$hsum{"$t"}{'nallelesexp'} = $tallelesexp;
	$hsum{"$t"}{'nalleles'} = $talleles;
	$hsum{"$t"}{'average'} = [@aexp];
	
	$tallelesexp = 0;
	undef @aexp;	
    }

    #Summarize total alleles by tissue and mean expression
    $concat = "";
    foreach my $t ("$t1","$t2","$t3") {
	$mean = sprintf("%3.3f", Math::NumberCruncher::Mean(\@{$hsum{"$t"}{'average'}}));
	$concat .= "$hsum{$t}{'nallelesexp'}\t$mean\t";

	if(scalar(@{$hsum{"$t"}{'average'}})) {
	    push @ameant, @{$hsum{"$t"}{'average'}};
	}
    }
    $stat->add_data(@ameant);
    $average = $stat->mean();
    ($CIMin,$CIMax) = ($stat->lower_clm(), $stat->upper_clm);

    %hsum = ();
    undef @ameant;

    for my $i (split(/\t/,$concat)) {
    	$next = 1 if($i > 12);
    }
    next if($next || $talleles > 12);
    printf "$talleles\t$concat%3.3f\t%3.3f\t%3.3f\n", $average, $CIMin, $CIMax;
}

#####################
#### Subrotines #####
#####################

#Read Tissue Alleles Expression 
sub readfile {    
    my ($file, $tissue) = @_;

    open(F,"$file");
    while(<F>) {
	if(/^\d+\t+(\S+)\t+(\S+)\t+(\S+)/) {
	    $hsamples{"$2"}{"$tissue"}{"$1"} = $3;
	}
    }
    close(F);
}

