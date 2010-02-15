#!/usr/bin/perl -w

use strict;

# Sequências
my @dna_sequences =  ("m2898.seq"); # split /\n/, `ls ../Sequencias/reais_dna`;
my @prot_sequences = ("m2636.seq"); # split /\n/, `ls ../Sequencias/reais_prot`;

# Hashes que mapeiam os parâmetros de entrada com os parâmetros do DiGrafu
my %params;
my %pvalues;

# Arrays auxiliares que armazenarão os valores possíveis de cada parâmetro
my @cv;
my @isite;
my @ratio;
my @freque;

my $seq = undef;

open REPORT, ">error_report.txt";

Main:

	my $type = $ARGV[0];			# Tipo de sequência
	my @p_list = split //, $ARGV[2];	# Lista com os parâmetros a serem analizados

	ajusta_parametros();			# Inicializa os hashes com os parâmetros comuns aos dois tipos de sequência

	# Teste de proteínas
	if($type =~ /^-p/){
		print "Testando DiGrafu - Proteína\n";
		print REPORT "Erros - Proteína\n";

		# Improviso para não passar para sequências de proteína
		# parâmetros somente válidos para sequências de dna
		my @p_list_prot;
		foreach my $i (@p_list){
			push (@p_list_prot, $i) if ($i <= 6);
		}

		# Inicializa os hashes com os parâmetros de proteína
		ajusta_parametrosPROT();
		# Testa o DiGrafu para todas as sequências de proteína encontradas 
		foreach $seq (@prot_sequences){
			teste_recursivo("../Run.pl INPUT ../Sequencias/reais_prot/$seq OUTPUT testOutput TYPE prot", @p_list_prot);
		}

	}
	# Teste de DNA
	if($type =~ /d$/){
		print "Testando DiGrafu - DNA\n";
		print REPORT "Erros - DNA\n";

		# Inicializa os hashes com os parâmetros de dna
		ajusta_parametrosDNA();
		# Testa o DiGrafu para todas as sequências de dna encontradas 
		foreach $seq (@dna_sequences){
			teste_recursivo("../Run.pl INPUT ../Sequencias/reais_dna/$seq OUTPUT testOutput TYPE dna", @p_list);
		}

	}

	# Seleção das operações baseada nos parâmetros de entrada
	# if($ARGV[1] eq "-c"){}
	elsif($ARGV[0] eq "-h"){
		print_help();
	}

#End Main

print "Teste completado!\n".
      "Ver relatório de erros: error_report.txt\n";

close REPORT;

exit(0);


#################################################################################
## Ajusta os parâmetros comuns aos dois tipos de sequência (dna e proteína)    ##
#################################################################################
sub ajusta_parametros{

	%params = (
		"1" => "PREFERENCE",
		"2" => "MODEL",
		"3" => "CV",
		"4" => "ISITE",
		"5" => "WEIGHT",	#Not implemented
		"6" => "CATEGORIES"	#Not implemented
	     );

	# PREFERENCE
	$pvalues{"1"} = ["a", "t", "ta"];

	# CV
	foreach my $i (1..10){
		$cv[$i-1] = $i/10;
	}
	$pvalues{"3"} = \@cv;

	# ISITE
	foreach my $i (1..99){
		$isite[$i-1] = $i/10;
	}
	$pvalues{"4"} = \@isite;

	# WEIGHT
	$pvalues{"5"} = [];

	# CATEGORIES
	$pvalues{"6"} = [];

}

#################################################################################
## Ajusta os parâmetros específicos de proteína				       ##
#################################################################################
sub ajusta_parametrosPROT{
	# MODEL
	$pvalues{"2"} = ["kimura", "pmb", "pam", "jtt"];
}

#################################################################################
## Ajusta os arâmetros específicos de dna				       ##
#################################################################################
sub ajusta_parametrosDNA{

	$params{"7"} = "RATIO";
	$params{"8"} = "FREQUE";

	# MODEL
	$pvalues{"2"} = ["kimura", "f84", "jc", "logdet"];

	# RATIO
	foreach my $i (0..10){
		push @ratio, $i/10;
	}
	$pvalues{"7"} = \@ratio;

	# FREQUE
	foreach my $a (0..4){
		foreach my $c (0..4){
			foreach my $g (0..4){
				foreach my $t (0..4){
					push @freque, (($a/4).",".($c/4).",".($g/4).",".($t/4));
				}
			}
		}
	}
	$pvalues{"8"} = \@freque;

}

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
	print "Types: -p  -  Protein\n";
	print "	      -d  -  DNA-\n";
	print "	      -pd -  Protein and DNA\n";
	print "\n";
	print "Options: -a  -  Test all parameters\n";				# Not implemented
	print "	        -c  -  Combine parameters\n";
	print "	        -ac -  Test all parameters an combine parameters\n";	# Not implemented
	print "         -h  -  Print this message and quit\n";
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
