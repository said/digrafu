#!/usr/bin/perl

use warnings;
use strict;

my $cont = 0;
my $linha = undef;
open ARQ, $ARGV[0];
my @line = undef;

while($linha = <ARQ>){
	@line = split //, $linha;
	for my $i(0..$#line){
		if($line[$i] =~ /[A-Za-z]/){
			$cont++;
		}
	}
}

close ARQ;

print $cont."\n";

srand((time() ^ (time() % $])) ^ exp(length($0))**$$);

open CAT, ">categories";
for my $i(1..365){
	print CAT int(rand(9))+1;
}
close CAT;


$cont = 0;
open CAT, "categories";

$linha = <CAT>;
@line = split //, $linha;
for my $i(0..$#line){
	if($line[$i] =~ /[1-9]/){
		$cont++;
	}
}

print $cont."\n";

close CAT;
