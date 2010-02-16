#!/usr/bin/perl -w

use strict;

my $dna_dir = "../Sequencias/reais_dna";
my $prot_dir = "../Sequencias/reais_prot";
my $out_dir = "validação2";
my $tree_dir = "";

my @dna_sequences = split /\n/, `ls $dna_dir`;
my @prot_sequences = split /\n/, `ls $prot_dir`;
my @tree_files = split /\n/, `ls $tree_dir`;
my @preference = ("a", "t", "ta");

my $option;
my $file;
my $tree;
my $pref;

Main:

	# Obtenção dos parâmetros	
	if(!@ARGV){ die "ERROR: No parameters input, type: treeUtils.pl -h\n" }

	foreach $option (@ARGV){

		if($option eq "1"){
			gera_arvores_digrafu();
		}
		elsif($option eq "2"){
			compara_arvores();
		}
		elsif($option eq "3"){
			conta_galhos();
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
## Executa o DiGrafu com as sequências em $dna_dir e $prot_dir		       ##
#################################################################################
sub gera_arvores_digrafu{

	foreach $pref (@preference){
		# DNA
		foreach $file(@dna_sequences){
				system("../Run.pl INPUT $dna_dir/$file OUTPUT  $out_dir/$tree_dir/$file"."_digrafu_tree_$pref.txt PREFERENCE $pref")
				&& die "erro ao executar o DiGrafu $?\n";
		}
		# Proteína
		foreach $file(@dna_sequences){
				system("../Run.pl INPUT $prot_dir/$file OUTPUT  $out_dir/$tree_dir/$file"."_digrafu_tree_$pref.txt PREFERENCE $pref MODEL jtt TYPE prot")
				&& die "erro ao executar o DiGrafu $?\n";
		}
	}

}


#################################################################################
## Compara as árvores geradas pelo digrafu em $tree_dir			       ##
## com a árvore gerada pelo PhyML					       ##
#################################################################################
sub compara_arvores{

	foreach $tree (@tree_files){

		if($tree =~ /(.+)_digrafu_tree_/){

			my $original_tree = $1."_phyml_tree.txt";

			foreach $pref (@preference){

				# Symetric Difference
				open TREEDIST, " | ./treedist " || die "erro ao executar treedist";
				print TREEDIST "$out_dir/$tree_dir/$original_tree\nd\n2\nc\nV\nY\n$out_dir/$tree_dir/$tree\n";
				close TREEDIST;

				system("mv outfile $out_dir/out_$tree") && die "erro ao renomear arquivo \"outfile\" $?";

				# Branch Score Distance
				open TREEDIST, " | ./treedist " || die "erro ao executar treedist";
				print TREEDIST "$out_dir/$tree_dir/$original_tree\n2\nc\nV\nY\n$out_dir/$tree_dir/$tree\n";
				close TREEDIST;

				system("mv outfile $out_dir/out_$tree"."_branchs") && die "erro ao renomear arquivo \"outfile\" $?";

			}

		}

	}

}


sub conta_galhos{}


#################################################################################
## Calcula o tamanho médio dos galhos das árvores geradas pelo DiGrafu	       ##
## e da árvore original gerada pelo PhyML				       ##
#################################################################################
sub calcula_medias{

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

	my @symetric_results = (0, 0, 0);
	my @branch_results = (0.33, 0.33, 0.31);
	my $numspecies = 10;
	my $qtgalhos = 2*$numspecies-3;
	my $maxvalue;
	my @maxvalues;
	my @finalvalues;
	my $line;
	my $num = 0;


	# topologica
	print "Diferenças simétricas:\n";
	$maxvalue = 2*$qtgalhos;
	foreach my $result (@symetric_results){
		print( (($maxvalue-$result)/$maxvalue)."\n" );
	}

	open MEDIAS, "$out_dir/medias" or die "erro ao abrir arquivo de medias\n";
	while ($line = <MEDIAS>){
		$line =~ /^(.+) (.+) (.+) (.+)$/;

		my $media = $4;
		push @maxvalues, 2*$qtgalhos*$media;

	}
	close MEDIAS;

	# galhos
	print "\nDistâncias entre galhos:\n";
	while($num <= $#branch_results){
		push( @finalvalues, (($maxvalues[$num])-$branch_results[$num])/($maxvalues[$num]) );
		print (($num+1)."  =>  ".$finalvalues[$num++]."\n");
	}

}


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

