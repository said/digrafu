#!/usr/bin/perl

use warnings;
use strict;

(scalar(@ARGV) == 2) or die "Uso correto:\n> ./gera_categories_file.pl <arquivo_sequencia> <numero_de_categorias>\n";

my $linha = undef;
my $cats = $ARGV[1];
my $n = "([0-9]+)";

open ARQ, $ARGV[0];

$linha = <ARQ>;
$linha =~ /^$n $n$/;
my $num_sites = $2;

close ARQ;

print $num_sites."\n";

srand((time() ^ (time() % $])) ^ exp(length($0))**$$);

open CAT, ">../Aux/categories";
for my $i(1..$num_sites){
	print CAT int(rand($cats))+1;
}

close CAT;
