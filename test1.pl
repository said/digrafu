#!/usr/bin/perl -w

use strict;

# open IN, "testInput";

my @dna_model = ("kimura", "f84", "jc", "logdet");
my @prot_model = ("kimura", "pmb", "pam", "jtt");

my $model = undef;

my $pwd = $0;
$pwd =~ s!/Run.pl!!;

# teste noparams
# my $arq = "$pwd/Sequencias/reais_dna/"
# system ("$pwd/Run.pl INPUT testInput OUTPUT testOutput");

# teste models

# dna
foreach $model (@dna_model){
	system ("$pwd/Run.pl INPUT testInput OUTPUT testOutput MODEL $model TYPE dna");
}

# prot
foreach $model (@prot_model){
	system ("$pwd/Run.pl INPUT testInput OUTPUT testOutput MODEL $model TYPE prot");
}
