#!/usr/bin/perl

use warnings;

@seqnumbers = ("2304", "2636", "2637", "2638", "2639", "2642", "2641")

foreach $seqnum (@seqnumbers){

	open(TREEDIST, " | ./treedist") || "erro ao executar treedist";
	print(TEEDIST, "m$seqnum.seq_phyml_tree.txt\nd\n2\nc\nV\nm$seqnum.seq_digrafu_tree.txt\n");
	close(TREEDIST);

	system("mv outfile out_m$seqnum") == 0 | die "erro ao renomear arquivo \"outfile\" $?";

}
