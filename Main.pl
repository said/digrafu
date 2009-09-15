#!/usr/bin/perl

	##########################################################
	## this file contains the main that will coordinate all ##
	## execution of the GRAFU's distance module. Your argu-	##
	## ments should be:										##
	## -name of input file (aligned sequences) 				##
	## -name of output file (format newick)  				##
	## -the preferential is the time of execution[t] or the ##
	##  accuracy[a]											##
	## -the input file contains sequences of DNA or protein ##
	## -model (DNA: f84, kimura, jc, logdet; Prot: jtt, pmb,##
	##  pam, kimura)										##
	##########################################################
	
	package Main;
    use MainUPGMA;
   	use MainBioNJ;
   	use MainModelFactory;
   	use MainWeighbor;
   	use MainNeighbor;
   	use MainConverter;
   	
    ##############################################################
	## below it is the code of the main program; starting from	##
	## him, the distance module is configured and executed		##
	##############################################################
	Main:
	{	
		my $instance = Parameters::getInstance;
		$instance->configure(@ARGV);
		my $filein = $instance->parameter("INPUT");
		my $preference = $instance->parameter("PREFERENCE");
		my $tempDir = $instance->parameter("TEMP");
						
		Converter::toSequential;
		
		AbstractMethod::executeMatrix;
		my $method;
		
		# se o tempo for preferido,
		# executa-se o bionj
		if($preference eq 't') {
			$method = new BioNJ;
		}
		else{
			&calculateFactor;
			
			my $model = ModelFactory::getInstance;
			$method = $model->chooseMethod;
		}
		$method->executeMethod;
		Converter::FileConfigure;
	}
    
    
    
    ##########################################################
	## method that calculates the maximum divergence among	##
	## the sequences										##
	##########################################################

	sub calculateFactor {
		my $instance = Parameters::getInstance;
		my $qletters = $instance->parameter("LETTER");
		my $sequencial = $instance->parameter("SEQUENTIAL");
    	#$sequencial =~ s/[ -?N0]/X/g;
	    my @sequences = split /\n/,$sequencial;

		my @matrix;
		for my $i(1..$#sequences) {
			$sequences[$i]=~/(.{$qletters})$/;
			@{$matrix[$i-1]} = split //,$1;
		}
		
		
		{
			my $i = 0;
		  	BLOCK:
		  	while($i <= $#{$matrix[0]}) {
		  	 	my $char = $matrix[0][$i];
		     	for my $j(1..$#matrix) {
					if($char ne $matrix[$j][$i]) {
		   	   			$i++;
		   	   			next BLOCK;
		   			}
		     	}
		     	for my $seq(0..$#matrix) {
		   			$matrix[$seq][$i] = $matrix[$seq][$#{$matrix[$seq]}];
		   			$#{$matrix[$seq]}--;
		    	}
			}
		}
		 
		my $largerDifference = 0;
		my $letters = $#{$matrix[0]};
		 
		for my $i (0..$#matrix-1) {
			for my $j ($i+1..$#matrix) {
				my $difference = 0;
		    	# AKI!!!!
				for my $l(0..$letters) {
					$difference++ if($matrix[$i][$l] =~ /[^ACGT]/ or
					   				 $matrix[$i][$l] ne $matrix[$j][$l]);
		      	}
		    	
				$largerDifference = ($difference > $largerDifference) ? $difference : $largerDifference;
			}
		}
		$largerDifference /= $qletters;
		$instance->parameter("LDIFFERENCE",$largerDifference);
		#return $largerDifference;
    }
    