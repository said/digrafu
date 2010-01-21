#!/usr/bin/perl

use warnings;

@seqnumbers = ("2304", "2636", "2637", "2638", "2639", "2640", "2641");

foreach $seqnum (@seqnumbers){

	system("../Run.pl INPUT ../Sequencias/reais_prot/m$seqnum.seq OUTPUT m$seqnum.seq_digrafu_tree.txt TYPE prot MODEL jtt\n") && die "erro ao executar digrafu $?\n";

}
