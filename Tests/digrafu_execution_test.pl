#!/usr/bin/perl -w

use strict;

my $testInput = "../Sequencias/reais_dna/m520.seq";

my @dna_model = ("kimura", "f84", "jc", "logdet");
my @prot_model = ("kimura", "pmb", "pam", "jtt");

my $model = undef;

open REPORT, ">error_report.txt";

# teste noparams
# my $arq = "$pwd/Sequencias/reais_dna/"
# system ("$pwd/Run.pl INPUT testInput OUTPUT testOutput");


# dna
print "Testando DiGrafu - DNA\n";
print REPORT "Erros - DNA\n";

# teste models
foreach $model (@dna_model){

	execute_digrafu("../Run.pl INPUT $testInput OUTPUT testOutput MODEL $model TYPE dna", "MODEL");

}

$testInput = "../Sequencias/reais_prot/m2304.seq";

# prot
print "Testando DiGrafu - Proteína\n\n";
print REPORT "Erros - Proteína\n\n";

# teste models
foreach $model (@prot_model){

	execute_digrafu("../Run.pl INPUT $testInput OUTPUT testOutput MODEL $model TYPE prot", "MODEL");

}

print "Teste completado!\nVer relatório de erros: error_report.txt\n";

close REPORT;


##################################################################################################

sub execute_digrafu{

	my $execution_string = shift;
	my $param = shift;

	open RUN, $execution_string." |";

	local $/;
	my $execution_output = <RUN>;

	if($execution_output){

		report_error("$param\n\n"."$execution_string\n\n".$execution_output);

	}

}

sub report_error{

	print REPORT "|--------------------------------------------------------------------\\\n".(shift)."\n";

}
