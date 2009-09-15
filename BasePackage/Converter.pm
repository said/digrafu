#!/usr/bin/perl

	use strict;
	use warnings;
	use MainConverter;
	use MainParameters;
	use File::Copy;
	use File::Spec;
	
	Main:
	{
		if(@ARGV == 0){
			&help;
			exit;
		}
		
		# captura caminho absoluto ate as pastas necessarias ao #
		# programa												#		
		my (undef,$exe) = File::Spec->splitpath( File::Spec->rel2abs( $0 ) );
		chop $exe;
		
		# configura singleton com argumentos					#
		my $instance = Parameters::getInstance;
		$instance->configure(@ARGV);
		
		# caminho completo para o arquivo de saida				#
		my $output = File::Spec->rel2abs( $instance->parameter( "OUTPUT" ) );
		my $outTemp = File::Spec->catfile(File::Spec->tmpdir(), 'sequencial.txt');
		$instance->parameter("TEMP",File::Spec->tmpdir());
		$instance->parameter("OUTPUT",$outTemp);
		
		# conversao propriamente dita							#
		Converter::toSequential;
		
		# configuracao de arquivos (com nomes reais ou menores)	#
		my $preference = $instance->parameter("TAXAS");
		&FileConfigure if ((!defined $preference) or ($preference ne 'p'));
		
		# salvando o resultado									#
		move $outTemp, $output;
	}

	# sub-rotina que garante a troca dos nomes reduzidos para	#
	# os nomes reais											#
	sub FileConfigure{
    	local $/;
    	my $instance = Parameters::getInstance;
    	my $names = $instance->parameter("NAMES");
    	my $fileOut = $instance->parameter("OUTPUT");
    	
    	local @ARGV = ($fileOut);
    	
    	$_ = <>;
    	close ARGV;
    	
    	for (my $i = $#{$names}; $i >= 0; $i--){
    		my $new = sprintf("%-10.10s","${$names}[$i]");
    		s/T$i\s+/$new/g;
    	}
		
		open OUTPUT, ">".$fileOut;
		print OUTPUT $_;
		close OUTPUT;
    }
	
	sub help{
		print "----------------------------Help\n";
		print "Converter.pm INPUT input OUTPUT output TAXAS name\n\n";
		print "Seus argumentos devem ser:\n";							
		print "input\t\t- nome do arquivo de entrada (sequencias alinhadas)\n";
		print "output\t\t- nome do arquivo de saida (formato sequencial)\n";
		print "name\t\t- os nomes devem ser Tn (menores)[g ou p]\n\n";
	}
