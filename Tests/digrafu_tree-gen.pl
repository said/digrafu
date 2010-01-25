#!/usr/bin/perl -w

@seqnumbers = ("2304", "2636", "2637", "2638", "2639", "2640", "2641");
@preference = ("a", "t", "ta");

foreach $seqnum (@seqnumbers){

	# system("../Run.pl INPUT ../Sequencias/reais_prot/m$seqnum.seq OUTPUT m$seqnum.seq_digrafu_tree.txt TYPE prot MODEL jtt\n") && die "erro ao executar digrafu $?\n";

	foreach $pref (@preference){

			system("../Run.pl INPUT ../Sequencias/reais_prot/m$seqnum.seq OUTPUT  m$seqnum.seq_digrafu_tree_$pref.txt PREFERENCE $pref MODEL jtt TYPE prot")
			&& die "erro ao executar digrafu $?\n";

	}


}
