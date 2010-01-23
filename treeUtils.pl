#!/usr/bin/env perl

use strict;
use Math::BigFloat;

my $file;
my $util;
my $scala;
my $i;

# getting parameters
for ($i = 0; $i <= $#ARGV; $i++)
{
	if ($ARGV[$i] eq "-f")
	{
		$i++;
		$file = $ARGV[$i];
	}
	elsif ($ARGV[$i] eq "-u")
	{
		$i++;
		$util = $ARGV[$i];
	}
	elsif ($ARGV[$i] eq "-s")
	{
		$i++;
		$scala = $ARGV[$i];
	}	
	elsif ($ARGV[$i] eq "-h")
	{
		print "Usage: treeUtils.pl [-t<treeFile>] [-u operation]\n";
		print "Options: -f = input file\n";
		print "         -u = utility operation (see the List of Utilities)\n";
		print "         -h = print this message and quit\n";
		print "\n";
		print "         List of Utilities\n";
		print "         1 - quantity and Sum tree branchs\n";
		print "         2 - convert e-XX notation to decimal values for tree branchs\n";
		print "         3 - pairwise divergence of sequence align\n";
		print "         4 - tree desviation clock to non-clock\n";
		print "         5 - tree scalling, enter -s <scalling number>\n";
		exit(0);
	}
	else
	{
		print "Don't understand argument: $ARGV[$i]\n";
		print "Usage: treeUtils.pl [-h]\n";
		exit(1); 
	}
}

die "ERROR: No parameters input, type: treeUtils.pl -h\n" if not $file or not $util;

# main
if ($util == 1) {
	my @info = treeInfo($file);
	for ($i=0; $i<@info; $i++){
		print $info[$i]."\n";
	}
}elsif ($util == 2){
	my $tree = decimalTreeBranch($file);
	print $tree."\n";	
	my @trees = treeInfo($file);
	for ($i=0; $i<@trees; $i++){
		print $trees[$i]."\n";
	}	
}elsif ($util == 3){
	taxonDivergence($file);	
}elsif ($util == 4){
	print desvioMC($file)."\n";
}elsif ($util == 5){
	die "Scalling value must be entered, see ./phyUtils -h\n" if not $scala;
	print escalona($file,$scala)."\n";
}


#functions

sub treeInfo{
	my @info;
	my $file = shift;
	my $sbl = 0;
	my $countBranch = 0;
	my $i;
	open( INFILE, $file ) or die "input tree file error\n";
	while(<INFILE>){
		while ($_ =~ /(\d+\.\d+)/g){
			$sbl = $sbl + $1;
			$countBranch++;
		}
		$info[$i++] = "Tree ".($i+1)." $countBranch $sbl";
		$countBranch = 0;
		$sbl = 0;
	}
	close INFILE;
	return @info;
}

sub decimalTreeBranch{
	my @trees;
	my $file = shift;
	my @distancias;
	my $count = 0;
	my $i;
	
	open( INFILE, $file ) or die "input tree file error\n";	

	while(<INFILE>){
		
		#pick all distance values
		$i = 0;
		while (/(\d+\.\d+e-\d+)/g){
			$distancias[$i++] = $1;
		}
		
		#replace all distances values for new values in decimal format
		for ($i=0; $i<@distancias; $i++){
			my $newNum = Math::BigFloat->new($distancias[$i])->bstr();
			s/$distancias[$i]/$newNum/;
		}
		
		$count++;
		$trees[$i] = $count.$_;
	}
	
	close INFILE;
	
	return @trees;
}

sub taxonDivergence{

	my $fileSeq = shift;
	my $qtdSites;
	my $qtdTax;
	my @seqs;
	my $sitesDiferentes;
	my $maxD; #divergência máxima entre taxons
	my $avgD; #divergência média entre taxons
	my $qtyD; #qtd distâncias
	my $strA;
	my $strB;
	my $i;
	my $j;
	my $k;
	my $l;
	my $m;
	my $n;
	
	open( IN, $fileSeq ) or die "Erro ao abrir arquivo contendo alinhamento de sequencias\n";
		
	$_ = <IN>;
	
	# obtendo qtd taxons
	if ($_ =~ /(\d+)\s/){
		$qtdTax = $1;
	}else{
		print "Não obteve qtd de taxas de $file!\n";
		exit(0);
	}	
	
	# obtendo qtd sites
	if ($_ =~ /\d+\s(\d+)/){
		$qtdSites = $1;
	}else{
		print "Não obteve qtd de sites de $file!\n";
		exit(0);
	}
	
	# obtendo sequencias de DNA
	for ($k=0; $k<$qtdTax; $k++){
		$_ = <IN>;
		if ($_ =~ /.+\s(.+)/){
			$seqs[$k] = $1;
		}else{
			print "Erro ao obter sequencia de DNA $k de $fileSeq\n";
		}
	}
	
	# comparando
	$maxD = 0;
	$avgD = 0;
	$qtyD = 0;
	for ($k=0; $k<$qtdTax-1; $k++){
		for ($l=$k+1; $l<$qtdTax; $l++){
			$sitesDiferentes = 0;
			for ($m=0; $m<$qtdSites; $m++){
				$strA = substr($seqs[$k],$m,1);
				$strB = substr($seqs[$l],$m,1);
				if ($strA ne $strB){
					$sitesDiferentes++;
				}
			}
			$avgD = $avgD + ($sitesDiferentes/$qtdSites);
			$qtyD = $qtyD + 1;
			if ($sitesDiferentes > $maxD){
				$maxD = $sitesDiferentes;
			}
			
		}
	}
	close IN;
		
	# resultado
	$avgD = $avgD/$qtyD;
	print "avg: $avgD\n";
	$maxD = $maxD/$qtdSites;
	print "max: $maxD\n";

}

#executa desvio molecular clock na árvore segundo Yang Syst. Biol. 47(1):125-133, 1998
sub desvioMC{
	my $file = shift;
	my @distancias;
	my @distNova;
	my $distPorcent = 0.75;
	my $arvore;	
	my $numAleat;
	my $galhoAleat;
	my $i;
	my $aux;
	
	#abre árvore a ser modificada
	open( IN, $file ) or die "Erro ao abrir arquivo contendo árvore\n";	
	$arvore = <IN>;
	close IN;	
	
	#recolhe todas as distancias da árvore
	$_ = $arvore;
	$i = 0;
	while (/(\d+\.\d+)/g){
		$distancias[$i++] = $1;
	}
	
	#copia distâncias para novo vetor
	for($i=0; $i<@distancias; $i++){
		$distNova[$i] = $distancias[$i];
	}
	
	#escolhe aleatoriamente $distPorcent das distâncias para multiplicar por sqrt(10)
	$aux = $distPorcent * @distancias;
	$aux = sprintf("%.0f", $aux); #arredondar $aux
	for($i=0; $i<$aux; $i++){
		$numAleat = sprintf("%.6f", rand()) * 1000000; #num aleatorio 6 digitos
		$galhoAleat = $numAleat % @distancias; #escolhe um galho aleatoriamente
		if (($numAleat % 2) == 0){ #escolhe com a mesmas prob, div ou mult por sqrt(10)
			$distNova[$galhoAleat] = $distancias[$galhoAleat] * sqrt(10);
		}else{
			$distNova[$galhoAleat] = $distancias[$galhoAleat] / sqrt(10);
		}
		$distNova[$galhoAleat] = sprintf("%0.6f", $distNova[$galhoAleat]); #arrend galho para 6 dig
	}
	
# 	#TESTE
# 	print "Qtd galhos modificados: $aux\n";
# 	$aux = @distancias;
# 	print "Qtd galhos total: $aux\n"; 
# 	for($i=0; $i<@distancias; $i++){
# 		print "$distancias[$i] - $distNova[$i]\n";
# 	}	
	
	#substitui as distâncias nova na árvore original
	$_ = $arvore;
	for ($i=0; $i<@distancias; $i++){
		s/$distancias[$i]/$distNova[$i]/;
	}
	
	return $_;
}

#executa escalonamento da árvore segundo valor informado
sub escalona{
	my $file = shift;
	my $val = shift;
	my @distancias;
	my @distNova;
	my $totGalhos = 0;
	my $escala;
	my $distPorcent = 0.75;
	my $arvore;	
	my $i;
	my $aux;
	
	#abre árvore a ser modificada
	open( IN, $file ) or die "Erro ao abrir arquivo contendo árvore\n";	
	$arvore = <IN>;
	close IN;	
	
	#recolhe todas as distancias da árvore
	$_ = $arvore;
	$i = 0;
	while (/(\d+\.\d+)/g){
		$distancias[$i++] = $1;
		$totGalhos = $totGalhos + $1;
	}
	
	#copia distâncias para novo vetor
	for($i=0; $i<@distancias; $i++){
		$distNova[$i] = $distancias[$i];
	}
	
	#escalonamento, $escala segundo Guindon & Gascuel, Syst. Biol. 52(5):696­704, 2003
	$escala = $val/$totGalhos;
	$_ = $arvore;
	for ($i=0; $i<@distancias; $i++){
		$aux = $distancias[$i]*$escala;
		$distNova[$i] = Math::BigFloat->new($aux)->bstr(); #retirar notação em pot de 10
		$distNova[$i] = sprintf("%0.6f", $distNova[$i]); #arrend galho para 6 dig
	}
	
# 	#TESTE
# 	print "Qtd galhos modificados: $aux\n";
# 	$aux = @distancias;
# 	print "Qtd galhos total: $aux\n"; 
# 	for($i=0; $i<@distancias; $i++){
# 		print "$distancias[$i] - $distNova[$i]\n";
# 	}
	
	#substitui as distâncias nova na árvore original
	$_ = $arvore;
	for ($i=0; $i<@distancias; $i++){
		s/$distancias[$i]/$distNova[$i]/;
	}
	
	return $_;
}
