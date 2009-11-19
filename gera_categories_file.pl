#!/usr/bin/perl

use warnings;
use strict;

(scalar(@ARGV) == 2) or die "Uso correto:\n> ./gera_categories_file.pl <arquivo_categories> <numero_de_categorias>\n";

my $linha = undef;

open ARQ, $ARGV[0];

my $cats = $ARGV[1];

my $line = undef;

$linha = <ARQ>;

my $n = "([0-9]+)";

$linha =~ /^$n $n$/;

my $num_sites = $2;

close ARQ;

print $num_sites."\n";

srand((time() ^ (time() % $])) ^ exp(length($0))**$$);

open CAT, ">Aux/categories";
for my $i(1..$num_sites){
	print CAT int(rand($cats))+1;
}

close CAT;

open CAT, "Aux/categories";

my $cont = 0;

$linha = <CAT>;
my @line = split //, $linha;
for my $i(0..$#line){
	if($line[$i] =~ /[1-9]/){
		$cont++;
	}
}

print $cont."\n";

close CAT;
