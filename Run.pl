#!/usr/bin/perl
	use strict;
	use warnings;
	
	##################################################################
	##  coordena o inicio da execucao do programa					##
	##################################################################

	Run:
	{
		# captura caminho absoluto ate as pastas necessarias ao 	#
		# programa													#
		my $pwd = $0;
		$pwd =~ s!/Run.pl!!;
		
		# chamada a impressao da ajuda do programa            		#
		if(@ARGV == 0) {

		   	open HELP, "$pwd/Doc/.help" or die "ERROR: $!";
		   	print <HELP>, "\n";
			close HELP;
			
		   	exit;
		}
		
		# a delecao da pasta temporaria aqui garante que essa pasta	#
		# sera deletada ainda que o programa nao obtenha sucesso na	#
		# execucao													#
		local $/;
		
		my $temp = "/tmp/.distancia.grafu";
		unlink </tmp/.distancia.grafu/*> or mkdir $temp;
		
		unshift @INC, "$pwd/BasePackage";
		push @ARGV, ("TEMP",$temp,"PWD",$pwd);
		
		open MAIN, "$pwd/Main.pl";
		eval <MAIN>;
		close MAIN;

		print $@ if $@;
		
		unlink </tmp/.distancia.grafu/*>;
		rmdir "$temp";
	}
