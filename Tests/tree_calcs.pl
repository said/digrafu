#!/usr/bin/perl -w

use strict;

my $option = $ARGV[0];
my $w = "(.+?)";

if(option == "1a"){

	open BRANCHES, "validação2/galhos" or die "falha ao abrir arquivo de galhos\n";
	open AVG, ">medias" or die "falha ao abrir arquivo de médias";

	my $line = <BRANCHES>;
	$line =~ /^$w $w $w $w$/;
	my $digrafuavg = $4/$3;

	$line = <BRANCHES>;
	$line =~ /^$w $w $w $w$/;
	my $phymlavg = $4/$3;

	my $finalavg = ($phymlavg+$digrafuavg)/2.0;
	print AVG "Media =>"." $finalavg\n";

	close BRANCHES;
	close AVG;

}
elsif($option == "1b"){

	open GPHYML, "galhos_phyml-treeutils.txt" or die "falha ao abrir arquivo galhos_phyml-treeutils.txt\n";
	open GDIGRAFU, "galhos_digrafu-treeutils.txt" or die "falha ao abrir arquivo galhos_digrafu-treeutils.txt\n";
	open OUT, ">medias.txt" or die "erro ao abrir arquivo de saída\n";
	my $line;

	foreach $line (<GPHYML>){

		$line =~ /^$w $w $w $w$/;

		my $phymlavg = $4/$3;

		my $i;
		foreach $i ((1,2,3)){

			my $line2 = <GDIGRAFU>;

			$line2 =~ /^$w $w $w $w$/;

			my $digrafuavg = $4/$3;
			my $finalavg = ($phymlavg+$digrafuavg)/2.0;
			print OUT "Media $2  =>"." $finalavg\n";

		}

	}

	close GPHYML;
	close GDIGRAFU;
	close OUT;

}
elsif($option == "2a"){

	open AVG, "medias" or die "erro ao abrir arquivo de medias\n";

	my @results = (0, 0, 0);
	my $Q = 17;
	my $maxvalue;
	my $line = <AVG>;
	$line =~ /^$w $w $w$/;

	# topologica		
	$maxvalue = 2*$Q;

	foreach my $r (@results){
		my $final_value = ($maxvalue-$r)/$maxvalue;
		print "$final_valuen\n";
	}

	close AVG;

}
elsif($option == "2"){

	my @results = (12, 12, 12, 4, 4, 8, 6, 6, 8, 6, 6, 2, 8, 8, 6, 0, 0, 0, 6, 4, 4);
	my @branch_results = (0.36, 0.36, 0.36, 0.47, 0.47, 0.48, 0.01, 0.01, 0.02, 0.02,
			      0.02, 0.02, 0.3, 0.3, 0.3, 0.08, 0.08, 0.09, 0.34, 0.34, 0.34);
	my @numspecies = (31, 20, 19, 18, 19, 18, 18);
	my @qtgalhos;
	my @maxvalues;
	my @finalvalues;
	my $line;
	my $num;

	foreach $num (@numspecies){
		push(@qtgalhos, 2*$num-3);
	}

	open MEDIAS, "medias.txt" or die "erro ao abrir arquivo de medias\n";

	while ($line = <MEDIAS>){
		$line =~ /^$w $w $w $w$/;

		# topologica		
		# push( @maxvalues, 2*($qtgalhos[($2-1)/3]) );

		# galhos
		my $media = $4;
		push( @maxvalues, 2*($qtgalhos[($2-1)/3])*$media );

		# print "$2  ".$maxvalues[$2-1]."\n";

	}

	close MEDIAS;

	$num = 0;
	while($num <= $#results){

		# topologica
		# push( @finalvalues, ($maxvalues[$num]-$results[$num])/$maxvalues[$num] );

		# galhos
		push( @finalvalues, ($maxvalues[$num]-$branch_results[$num])/$maxvalues[$num] );

		print (($num+1)."  =>  ".$finalvalues[$num++]."\n");

	}

}
