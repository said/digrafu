#!/usr/bin/perl -w

use strict;


my %params;
my %pvalues;
# my %dna_params = undef;
# my %dna_pvalues = undef;
# my %prot_params = undef;
# my %prot_pvalues = undef;
my @dna_sequences =  split /\n/, `ls ../Sequencias/reais_dna`;
my @prot_sequences = split /\n/, `ls ../Sequencias/reais_prot`;

my $seq = undef;

open REPORT, ">error_report.txt";

Main:

	# Inicialização de variáveis
	my $type = $ARGV[0];			# Tipo de sequência
	my @p_list = split //, $ARGV[2];	# Lista com os parâmetros a serem analizados

	# Teste de DNA
	if($type =~ /^-d/){

		# Inicializa os hashes de parâmetros
		%params = (
			"1" => "PREFERENCE",
			"2" => "MODEL",
			"3" => "CV",
			"4" => "ISITE",
			"5" => "WEIGHT",
			"6" => "CATEGORIES",
			"7" => "RATIO",
			"8" => "FREQUE"
		     );
		$pvalues{"1"} = ["a", "t", "ta"];
		$pvalues{"2"} = ["kimura", "f84", "jc", "logdet"];

		my @cv = undef;
		foreach my $i (1..100){
			$cv[$i-1] = $i/10;
		}
		$pvalues{"3"} = \@cv;
		$pvalues{"4"} = [];
		$pvalues{"5"} = [];
		$pvalues{"6"} = [];
		$pvalues{"7"} = [];
		$pvalues{"8"} = [];
		
		print "Testando DiGrafu - DNA\n";
		print REPORT "Erros - DNA\n";

		# Testa o DiGrafu para todas as sequências de dna encontradas 
		foreach $seq (@dna_sequences){
			teste_recursivo("../Run.pl INPUT ../Sequencias/reais_dna/$seq OUTPUT testOutput", @p_list);
		}

	}
	# Teste de proteínas
	if($type =~ /p$/){

		# Inicializa os hashes de parâmetros
		%params = (
			"1" => "PREFERENCE",
			"2" => "MODEL",
			"3" => "CV",
			"4" => "ISITE",
			"5" => "WEIGHT",
			"6" => "CATEGORIES"
		     );
		$pvalues{"1"} = ["a", "t", "ta"];
		$pvalues{"2"} = ["kimura", "pmb", "pam", "jtt"];
		$pvalues{"3"} = [];
		$pvalues{"4"} = [];
		$pvalues{"5"} = [];
		$pvalues{"6"} = [];
 		
		print "Testando DiGrafu - Proteína\n";
		print REPORT "Erros - Proteína\n";

		# Testa o DiGrafu para todas as sequências de proteína encontradas 
		foreach $seq (@prot_sequences){
			teste_recursivo("../Run.pl INPUT ../Sequencias/reais_prot/$seq OUTPUT testOutput", @p_list);
		}

	}

	# Seleção das operações baseada nos parâmetros de entrada
	# if($ARGV[1] eq "-c"){}
	elsif($ARGV[0] eq "-h"){
		print_help();
	}

#End Main

print "Teste completado!\nVer relatório de erros: error_report.txt\n";

close REPORT;

exit(0);


#################################################################################
## Aplica as várias combinações aos prâmetros e os combina recursivamente      ##
#################################################################################
sub teste_recursivo{

	my $exec_string = shift;
	my $param = shift;
	my $p = $pvalues{$param};

	$exec_string .= " ".$params{$param};
	# Parada
	unless(@_){
		foreach my $value (@$p){
			execute_digrafu($exec_string." $value");
			print $exec_string." $value\n";
		}
		return;
	}

	foreach my $value (@$p){
		execute_digrafu($exec_string." $value");
		print $exec_string." $value\n";
		teste_recursivo($exec_string." $value", @_);
	}

}


#################################################################################
## Executa o DiGrafu com a string recebida como parâmetro		       ##
#################################################################################
sub execute_digrafu{

	my $execution_string = shift;

	open RUN, $execution_string." |";

	local $/;
	my $execution_output = <RUN>;

	if($execution_output){

		report_error("$execution_string\n\n".$execution_output);

	}

}


#################################################################################
## Imprime o erro encontrado no arquivo error_report.txt		       ##
#################################################################################
sub report_error{

	print REPORT "|--------------------------------------------------------------------\\\n".(shift)."\n";

}


#################################################################################
## Imprime a ajuda de utilização do programa				       ##
#################################################################################
sub print_help{

	print "Usage: digrafu_execution_test.pl <type> <options> <params_list> \n";
	print "Types: -d - DNA\n";
	print "	      -p - Protein\n";
	print "	      -pd - DNA and protein\n";
	print "\n";
	print "Options: -a - Test all parameters\n";				# Not implemented
	print "	        -c - Combine parameters\n";
	print "	        -ac - Test all parameters an combine parameters\n";	# Not implemented
	print "         -h - Print this message and quit\n";
	print "\n";
	print "         List of parameters:\n";
	print "           1  -  PREFERENCE\n";
	print "           2  -  MODEL\n";
	print "           3  -  CV\n";
	print "           4  -  ISITE\n";
	print "           5  -  WEIGHT\n";
	print "           6  -  CATEGORIES\n";
	print "           7  -  RATIO (only for DNA)\n";
	print "           8  -  FREQUE (only for DNA)\n";
	exit(0);

}
