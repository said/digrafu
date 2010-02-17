#!/usr/bin/perl -w

use strict;

# Colocar os caminhos dos diretórios que serão usados na validação
# (obs: caminhos relativos a pasta digrafu/Test, onde deve estar localizado este arquivo)
my $dna_dir = "sequencias/dna";
my $prot_dir = "sequencias/prot";
my $out_dir = "validacao3";
my $tree_dir = "trees";
my $phyml_dir = "PhyML_3.0";

# Arquivo com os resultados obtidos na validação
my $tabela = "resultados";

my @dna_sequences = split /\n/, `ls $dna_dir`;
my @prot_sequences = split /\n/, `ls $prot_dir`;
my @preference = ("a", "ta", "t");

my $option;
my $file;
my $tree;
my $pref;


Main:

	# Obtenção dos parâmetros	
	if(!@ARGV){ die "ERROR: No parameters input, type: treeUtils.pl -h\n" }

	foreach $option (@ARGV){

		if($option eq "1"){
			gera_arvores();
		}
		elsif($option eq "2"){
			compara_arvores();
		}
		elsif($option eq "3"){
			cria_arquivos_arvores();
		}
		elsif($option eq "4"){
			calcula_medias();
		}
		elsif($option eq "5"){
			padroniza_valores();
		}
		elsif($option eq "-h"){
			print_help();
		}
		else{
			print "Argumento \"$option\" invalido!\n";
			print "Use treeUtils.pl [-h] para ver\n";
			exit(1); 
		}
	}

#End Main


#################################################################################
## Executa o DiGrafu com as sequências em $dna_dir e $prot_dir.		       ##
## São geradas árvores utilizando os três valores possíveis para o parâmetro   ##
## PREFERENCE e coloca os arquivos em $tree_dir				       ##
#################################################################################
sub gera_arvores{

	# DNA		(obs: todos os arquivos devem ter o mesmo formato -> phylip sequencial | intercalado)
	foreach $file (@dna_sequences){

		# PhyML
		system("./$phyml_dir/PhyML_3.0_linux32 -i $dna_dir/$file -d nt -q -m K80 -v e -t e -c 4 -a e -o tlr")
		&& die "erro ao executar o PhyML $?\n";
		system("mv $dna_dir/$file"."_phyml* $out_dir/$tree_dir") && die "erro ao mover árvore gerada pelo PhyML $?\n";

		# DiGrafu
		foreach $pref (@preference){
			system("../Run.pl INPUT $dna_dir/$file OUTPUT $out_dir/$tree_dir/$file"."_digrafu_tree_$pref.txt PREFERENCE $pref TYPE dna MODEL kimura")
			&& die "erro ao executar o DiGrafu $?\n";
		}

	}
	# Proteína	(obs: todos os arquivos devem ter o mesmo formato -> phylip sequencial | intercalado)
	foreach $file (@prot_sequences){

		# PhyML
		system("./$phyml_dir/PhyML_3.0_linux32 -i $prot_dir/$file -d aa -m JTT -v e -c 4 -a e -o tlr")
		&& die "erro ao executar o PhyML $?\n";
		system("mv $prot_dir/$file"."_phyml* $out_dir/$tree_dir") && die "erro ao mover árvore gerada pelo PhyML $?\n";

		# DiGrafu
		foreach $pref (@preference){
			system("../Run.pl INPUT $prot_dir/$file OUTPUT  $out_dir/$tree_dir/$file"."_digrafu_tree_$pref.txt PREFERENCE $pref TYPE prot MODEL jtt")
			&& die "erro ao executar o DiGrafu $?\n";
		}

	}

}


#################################################################################
## Cria um arquivo com todas as árvores para ser			       ##
## usado no Treedist e no treeUtils					       ##
#################################################################################
sub cria_arquivos_arvores{

	my @phyml_trees = split /\n/, `ls $out_dir/$tree_dir/*_phyml_tree.txt`; # OBS: os nomes dos arquivos ficarão com os nomes das pastas
	my @digrafu_trees;
	local $/;

	foreach my $phyml_tree (@phyml_trees){

		$phyml_tree =~ /$out_dir\/$tree_dir\/(.+)_phyml_tree.txt/;
		open TREEFILE, ">$out_dir/$tree_dir/all_trees_$1.txt" or die "erro ao abrir arquivo de árvores $?\n";
		my $filename = $1."_digrafu_tree_*.txt";
		@digrafu_trees = split /\n/, `ls $out_dir/$tree_dir/$filename`;


		foreach my $digrafu_tree (@digrafu_trees){
			open PHYML, "$phyml_tree";
			$_ = <PHYML>;
			s/[\s]*//g;
			print TREEFILE "$_\n";

			open DIGRAFU, "$digrafu_tree";
			$_ = <DIGRAFU>;
			s/[\s]*//g;
			print TREEFILE "$_\n";
		
			close DIGRAFU;
			close PHYML;

		}

		close TREEFILE;

	}


}


#################################################################################
## Compara as árvores geradas pelo digrafu em $tree_dir			       ##
## com a árvore gerada pelo PhyML					       ##
#################################################################################
sub compara_arvores{

	cria_arquivos_arvores();

	#system("rm outfile") && die "erro ao remover arquivo \"outfile\" $?";

	my @all_tree_files = `ls $out_dir/$tree_dir/all_trees_*.txt`;

	foreach my $tree_file (@all_tree_files){
		
		$tree_file =~ /$out_dir\/$tree_dir\/all_trees_(.+).txt/;
		my $filename = $1;

		# Symetric Difference
		open TREEDIST, " | ./treedist " || die "erro ao executar o Treedist $?\n";
		print TREEDIST "$tree_file"."D\n2\nA\nS\nY\n";
		close TREEDIST;

		system("mv outfile $out_dir/dist_trees_$filename.txt") && die "erro ao renomear arquivo \"outfile\" $?";

		# Branch Score Distance
		open TREEDIST, " | ./treedist " || die "erro ao executar o Treedist $?\n";
		print TREEDIST "$tree_file"."2\nA\nS\nY\n";
		close TREEDIST;

		system("mv outfile $out_dir/dist_trees_$filename"."_branchs.txt") && die "erro ao renomear arquivo \"outfile\" $?";

		calcula_medias($filename);

	}

}


#################################################################################
## Calcula o tamanho médio dos galhos das árvores geradas pelo DiGrafu	       ##
## e da árvore original gerada pelo PhyML				       ##
#################################################################################
sub calcula_medias{

	my $treefile = shift;
	my $phymlavg;
	my $digrafuavg;
	my $media;
	my $line;
	my $branches;

	open BRANCHES, "./treeUtils.pl -f $out_dir/$tree_dir/all_trees_$treefile.txt -u 1 |" || die "erro ao executar \"treeUtils.pl -f $out_dir/$tree_dir/all_trees_$treefile.txt -u 1\"\n";
	open AVG, ">>$out_dir/medias" or die "falha ao abrir arquivo de médias";

	print AVG "$treefile\t";

	foreach $pref (@preference){
		
		$line = <BRANCHES>;
		$line =~ /^(.+) (.+) (.+) (.+)$/;
		$phymlavg = $4/$3;
		$line = <BRANCHES>;
		$line =~ /^(.+) (.+) (.+) (.+)$/;
		$digrafuavg = $4/$3;
		$media = ($phymlavg+$digrafuavg)/2.0;

		print AVG "\t$media";
		$branches = $3;
	}

	print AVG "\t$branches\n";

	close AVG;
	close BRANCHES;

}


sub calcula_medias_old{

	my $line;

	open BRANCHES, "$out_dir/galhos" or die "falha ao abrir arquivo de galhos\n";
	open AVG, ">$out_dir/medias" or die "falha ao abrir arquivo de médias";

	$line = <BRANCHES>;
	$line =~ /^(.+) (.+) (.+) (.+)$/;
	my $phymlavg = $4/$3;

	foreach $line (<BRANCHES>){

		$line =~ /^(.+) (.+) (.+) (.+)$/;
		my $digrafuavg = $4/$3;

		my $finalavg = ($phymlavg+$digrafuavg)/2.0;
		print AVG "Media $2  =>"." $finalavg\n";

	}

	close BRANCHES;
	close AVG;

}


#################################################################################
## Faz a padronização dos resultados das comparações entre as árvores	       ##
#################################################################################
sub padroniza_valores{

	my $max_qt;
	my @max_qt_br;
	my $maxvalue;
	my $result;
	my $line2;

	open TAB, ">$out_dir/$tabela" or die "erro ao abrir arquivo de resultados finais\n";

	open AVG, "$out_dir/medias" or die "erro ao abrir arquivo de médias\n";
	foreach my $line (<AVG>){

		if($line =~ /^(\S+)\s+(\S+)\s+(\S+)\s(\S+)\s+(\S+)$/){

			my $qt;
			my $seq = $1;
			my $media_a = $2;
			my $media_ta = $3;
			my $media_t = $4;
			my $nbranches = $5;
			my $type;

			my $seqdir;
			foreach my $sequence (@dna_sequences){
				if($seq eq $sequence){
					$seqdir = $dna_dir;
					$type = "dna";
				}
				else{
					$seqdir = $prot_dir;
					$type = "proteina";
				}
			}
			open SEQ, "$seqdir/$seq" or die "erro ao abrir arquivo de sequência\n";

			my $info = <SEQ>;
			$info =~ /(\d+)\s+(\d+)/;
			my $species = $1;
			my $sites = $2;
			close SEQ;

			$qt = (2*$species-3);
			print TAB "$seq\t$type\t$species\t$sites\t$nbranches\t";

			# Topologica
			open SD, "$out_dir/dist_trees_$seq.txt" or die "erro ao abrir arquivo de topologias\n";
			foreach my $line (<SD>){

				$line =~ /\s(\S+)$/;
				$result = $1;
				$maxvalue = 2*$qt;

				print TAB ( "$result\t".(($maxvalue-$result)/$maxvalue)."\t" );


			}
			close SD;

			open BSD, "$out_dir/dist_trees_$seq"."_branchs.txt" or die "erro ao abrir arquivo de galhos\n";
			# Galhos
			$line2 = <BSD>;
			$line2 =~ /.+\s(\S+)$/;
			$result = $1+0;
			$maxvalue = 2*$qt*$media_a;
			print TAB ( "$result\t".(($maxvalue-$result)/$maxvalue)."\t" );
			$maxvalue = 2*$qt*$media_ta;
			print TAB ( "$result\t".(($maxvalue-$result)/$maxvalue)."\t" );
			$maxvalue = 2*$qt*$media_t;
			print TAB ( "$result\t".(($maxvalue-$result)/$maxvalue)."\n" );

			close BSD;

		}

	}
	close AVG;
	close TAB;

}


sub clean{}


#################################################################################
## Imprime a ajuda de utilização do programa				       ##
#################################################################################
sub print_help{

	print "Usage: treeCalcs.pl <option>\n";
	print "Options:\n";
	print "         1 - Gera árvores pelo DiGrafu\n";
	print "         2 - Compara com a árvore do PhyML\n";
	print "         3 - Conta os galhos de cada árvore\n";
	print "         4 - Calcula médias\n";
	print "         5 - Padroniza valores\n";
	exit(0);

}

