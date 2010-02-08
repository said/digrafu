#!/usr/bin/perl -w

@seqnumbers = ("2304", "2636", "2637", "2638", "2639", "2640", "2641");
@preference = ("a", "t", "ta");

foreach $seqnum (@seqnumbers){

	foreach $pref (@preference){

		open TREEDIST, " | ./treedist " || die "erro ao executar treedist";
		print TREEDIST "m$seqnum.seq_phyml_tree.txt\n2\nc\nV\nY\nm$seqnum.seq_digrafu_tree_$pref.txt\n";
		close TREEDIST;

		system("mv outfile out_m$seqnum"."_$pref"."_branchs") && die "erro ao renomear arquivo \"outfile\" $?";

	}

}
