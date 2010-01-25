#!/usr/bin/perl -w

use strict;

my @dna_seqnumbers = ("62", "520", "535", "536", "795", "925", "926");

my @prot_seqnumbers = ("2304", "2636", "2637", "2638", "2639", "2640", "2641");

my @preference = ("a", "t", "ta");

my @dna_model = ("kimura", "f84", "jc", "logdet");
my @prot_model = ("kimura", "pmb", "pam", "jtt");

my $seqnum = undef;
my $model = undef;
my $pref = undef;

open REPORT, ">error_report.txt";

# teste noparams
# my $arq = "$pwd/Sequencias/reais_dna/"
# system ("$pwd/Run.pl INPUT testInput OUTPUT testOutput");


# dna
print "Testando DiGrafu - DNA\n";
print REPORT "Erros - DNA\n";

foreach $seqnum (@dna_seqnumbers){

	# preference

	foreach $pref (@preference){

		# teste models
		foreach $model (@dna_model){

			execute_digrafu("../Run.pl INPUT ../Sequencias/reais_dna/m$seqnum.seq OUTPUT testOutput PREFERENCE $pref MODEL $model TYPE dna", $seqnum);

		}

	}

}

# prot
print "Testando DiGrafu - Proteína\n";
print REPORT "Erros - Proteína\n";

foreach $seqnum (@prot_seqnumbers){

	# preference

	foreach $pref (@preference){

		# teste models
		foreach $model (@prot_model){

			execute_digrafu("../Run.pl INPUT ../Sequencias/reais_prot/m$seqnum.seq OUTPUT testOutput PREFERENCE $pref MODEL $model TYPE prot", $seqnum);

		}

	}

}

print "Teste completado!\nVer relatório de erros: error_report.txt\n";

close REPORT;


##################################################################################################

sub execute_digrafu{

	my $execution_string = shift;
	my $seq = shift;

	open RUN, $execution_string." |";

	local $/;
	my $execution_output = <RUN>;

	if($execution_output){

		report_error("$seq\n\n"."$execution_string\n\n".$execution_output);

	}

}

sub report_error{

	print REPORT "|--------------------------------------------------------------------\\\n".(shift)."\n";

}
