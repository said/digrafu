#!/usr/bin/perl -w

@files = ("5Genes.1+8.phy"); # ("2304", "2636", "2637", "2638", "2639", "2640", "2641");
@preference = ("a", "t", "ta");

foreach $file (@files){

	foreach $pref (@preference){

		# Symetric Difference
		open TREEDIST, " | ./treedist " || die "erro ao executar treedist";
		print TREEDIST "validação2/$file"."_phyml_tree.txt\nd\n2\nc\nV\nY\nvalidação2/$file"."_digrafu_tree_$pref.txt\n";
		close TREEDIST;

		system("mv outfile validação2/out_$file"."_$pref") && die "erro ao renomear arquivo \"outfile\" $?";

		# Branch Score Distance
		open TREEDIST, " | ./treedist " || die "erro ao executar treedist";
		print TREEDIST "validação2/$file"."_phyml_tree.txt\n2\nc\nV\nY\nvalidação2/$file"."_digrafu_tree_$pref.txt\n";
		close TREEDIST;

		system("mv outfile validação2/out_$file"."_$pref"."_branchs") && die "erro ao renomear arquivo \"outfile\" $?";

	}

}
