#!/usr/bin/perl -w

use strict;

if(@ARGV != 2) {
    die "Usage: $0 <pair_sugarcane_sorghum_genes_file> <gff_file>\n";
}

my $falleles = shift;

my %hall = ();

open(F,"$falleles");
while(<F>) {
    $hall{"$1"} = "$2" if(/^evm.model.(\S+)\t+(\S+)/);
}
close(F);

my $v = "";
my $vaux = "";
my $gene = "";
my $sorgo = "";
while(<>) {
    next if(!/\tmRNA\t/);

    if( (/\;Parent=(S\S+)\.(scga7\S+)/) || (/ID=(S\S+)\.(scga7\S+)\;Name/) ) {
	$gene = "$2";	
	$sorgo = "$1";

	if(exists $hall{"$gene"}) {
	    s/ID=$sorgo.*/gene_id ""; transcript_id "${sorgo}.${gene}"; TPM "$hall{$gene}"/;
	    print;
	}
    }
}
