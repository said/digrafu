	##################################################
	## that class serves as base to classes of 	    ##
	## methods to simplification of the main with	##
	## the use of the polimorfism					##
	##################################################

    package AbstractMethod;
   	use strict;
    use warnings;
   	use MainParameters;
   	use File::Copy;

    ##################################################
    ## methods implementations		    			##
    ##################################################
	
	## method to implementation in subclasses		##
	
	sub executeMethod;
	
	## private methods								##
	
	my $_dying = sub {
		my $instance = $_[1];
		my $tempDir = $instance->parameter("TEMP");
		unlink <./outfile>;
		print "DNADIST ERROR:\n";
		system "cat $tempDir/dnadistlog | grep WARNING";
		system "cat $tempDir/dnadistlog | grep ERROR";
		die "";
	};
	
	my $_executeDNADist = sub  {
		
		my $instance = $_[1];
		my $pwd = $instance->parameter("PWD");
		my $model = $instance->parameter("MODEL");
		my $tempDir = $instance->parameter("TEMP");
		my $fileIn = $instance->parameter("INPUT");
	       	my $weight = $instance->parameter("WEIGHT");
		my $letters = $instance->parameter("LETTER");
		my $ratio = $instance->parameter("RATIO");
		my $gamma = $instance->parameter("GAMMA");
		my $freque = $instance->parameter("FREQUE");
		my $alpha = $instance->parameter("ALPHA");
		my $fraction = $instance->parameter("ISITE");
		my $categories = $instance->parameter("CATEGORIES");
        
		my $parameters = $fileIn."\n";

		# Seta modelo kimura como padrão
		my $modelValue = 1;

		# Verificação do modelo escolhido 
		if( defined $model && !($model =~ /^k/) ){
			if($model =~ /^f/) {
				$modelValue = 0;
			}
			elsif($model =~ /^j/) {
				$modelValue = 2;
			}
			elsif($model =~ /^l/) {
				$modelValue = 3;
				$gamma = 0;
				$categories = undef;
			}
			else{
				print "Argumento invalido: modelo inexistente\n";
				exit;
			}
		}
		for my $i (1..$modelValue) {
			$parameters .= "D\n";
		}
		
		if(defined $categories){
			# Avalia se o argumento passado para CATEGORIES é válido e faz o tratamento adequado
			if($categories =~ /^(-?[0-9]*\.?[0-9]+)(,(-?[0-9]*\.?[0-9]+))*$/){

				my @cat = split /,/,$categories;

				if((@cat >= 1) && (@cat <= 9)){
					$parameters .= "C\n".scalar(@cat)."\n@cat\n";
				}
				else{
					print "Argumento invalido: o numero de categorias deve estar entre 1 e 9\n";
					exit;
				}
			}
			else{
				print "Argumento invalido: CATEGORIES deve ser uma sequencia de um a nove numeros ".
				      "inteiros ou reais separados por virgula e sem espacos\n";
				exit;
			}
		}

		if(defined $ratio){
			if($modelValue == 0 || $modelValue == 1){
				if($ratio >= 0){
					$parameters .= "T\n$ratio\n";
				}
				else{
					print "Argumento invalido: RATIO deve ser maior ou igual a 0\n";
					exit;
				}
			}
			else{
				print "Input error: RATIO nao e usado no modelo escolhido\n";
				exit;
			}
		}
		
		if($modelValue != 3) {
			for my $i(1..$gamma){
				$parameters .= "G\n";
			}
		}
		
		if($modelValue == 0 && defined $freque && (@_ = split /,/,$freque) == 4){
			$parameters .= "F\n".join(" ",@_)."\n";
		}
		
		$parameters .= "I\n2\n";
		
		if(defined $weight && $weight =~ /^[0-9]+(,[0-9]+)*$/) {
			$parameters .= "W\n";
			$parameters .= "Y\n";
			
			if($gamma > 0){
				$parameters .= "$alpha\n";
				if($gamma > 1){
					$parameters .= "$fraction\n";
				}
			}
			
			$parameters .= "$tempDir/weights\n";

			my @sites = split /,/,$weight;
			my @weights;
			for my $i(0..$letters-1) {
				$weights[$i] = 0;
			}
			for my $i(0..$#sites) {
				$weights[$sites[$i] - 1] = 1;
			}
			
			open WEIGHTS, ">$tempDir/weights";
			print WEIGHTS join "",@weights;
			close WEIGHTS;
		}
		else{
			$parameters .= "Y\n";
			
			if($gamma > 0){
				$parameters .= "$alpha\n";
				if($gamma > 1){
					$parameters .= "$fraction\n";
				}
			}
		}
		print $parameters;
		exit;
		open MATRIZDNA, ">".$tempDir."/parameters"
			  or die "ERROR: Unable open file: $tempDir/parameters.\n$!\n";
		print MATRIZDNA $parameters;
		close MATRIZDNA;
		
		
		(system("$pwd/Exe/dnadist < $tempDir/parameters > $tempDir/dnadistlog") == 0
			and move("outfile","$tempDir/matrix"))
			or &$_dying;
	};
	
	my $_executeProtDist = sub {

		my $instance = $_[1];

		my $pwd = $instance->parameter("PWD");
		my $model = $instance->parameter("MODEL");
		my $tempDir = $instance->parameter("TEMP");
		my $fileIn = $instance->parameter("INPUT");
		my $gamma = $instance->parameter("GAMMA");
		my $weight = $instance->parameter("WEIGHT");
		my $letters = $instance->parameter("LETTER");
		my $alpha = $instance->parameter("ALPHA");
		my $fraction = $instance->parameter("ISITE");
		my $categories = $instance->parameter("CATEGORIES");
		my $parameters = $fileIn."\n";

		# Seta modelo kimura como padrão
		my $modelValue = 3;

		# Caso o usuário tenha definido um modelo, verifica o modelo escolhido 
		if( defined $model && !($model =~ /^k/) ){
			if($model =~ /^jt/) {
				$modelValue = 0;
			}			
			elsif($model =~ /^pm/) {
				$modelValue = 1;
			}
			elsif($model =~ /^pa/) {
				$modelValue = 2;
			}
			else{
				print "Argumento invalido: modelo inexistente\n";
				exit;
			}
		}
		else{ $gamma = 0 }

		for my $i (1..$modelValue) {
			$parameters .= "P\n";
		}
		
		if($modelValue != 3) {
			for my $i(1..$gamma){
				$parameters .= "G\n";
			}
		}

		if(defined $categories){
			# Avalia se o argumento passado para CATEGORIES é válido e faz o tratamento adequado
			if($categories =~ /^(-?[0-9]*\.?[0-9]+)(,(-?[0-9]*\.?[0-9]+))*$/){

				my @cat = split /,/,$categories;

				if((@cat >= 1) && (@cat <= 9)){
					$parameters .= "C\n".scalar(@cat)."\n@cat\n";
				}
				else{
					print "Argumento invalido: o numero de categorias deve estar entre 1 e 9\n";
					exit;
				}
			}
			else{
				print "Argumento invalido: CATEGORIES deve ser uma sequencia de um a nove numeros ".
				      "inteiros ou reais separados por virgula e sem espacos\n";
				exit;
			}
		}

		$parameters .= "I\n2\n";

		if(defined $weight && $weight =~ /^[0-9]+(,[0-9]+)*$/) {
			$parameters .= "W\n";
			$parameters .= "Y\n";
			
			if($gamma > 0){
				$parameters .= "$alpha\n";
				if($gamma > 1){
					$parameters .= "$fraction\n";
				}
			}
			
			$parameters .= "$tempDir/weights\n";

			my @sites = split /,/,$weight;
			my @weights;
			for my $i(0..$letters-1) {
				$weights[$i] = 0;
			}
			for my $i(0..$#sites) {
				$weights[$sites[$i] - 1] = 1;
			}
			
			open WEIGHTS, ">$tempDir/weights";
			print WEIGHTS join "",@weights;
			close WEIGHTS;
		}
		else{
			$parameters .= "Y\n";
			
			if($gamma > 0){
				$parameters .= "$alpha\n";
				if($gamma > 1){
					$parameters .= "$fraction\n";
				}
			}
		}

	#	if(defined $weight && $weight eq "y") {
	#		$parameters .= "W\n";
	#	}
	#	
	#	if($modelValue != 3 && defined $gamma && $gamma eq "y") {
	#		$parameters .= "G\n";
	#		if($gamma eq "gi") {
	#			$parameters .= "G\n";
	#		}
	#	}
		
		
		
		print $parameters;
		exit;

		open MATRIZPROT, ">".$tempDir."/parameters"
			   or die "ERROR: Unable open file: $tempDir/parameters.\n$!\n";
		print MATRIZPROT $parameters;
		close MATRIZPROT;
		
		system "$pwd/Exe/protdist < $tempDir/parameters > $tempDir/protdistlog";
		move "./outfile", "$tempDir/matrix";
	};
	
	## captures parameters and chooses the ma-	##
	## trix construction method					##
	
	sub executeMatrix {
   		my $self = shift;
       	my $instance = Parameters::getInstance;
       	if($instance->parameter("TYPE") =~ /^d/){	#DNA sequence
       		$self->$_executeDNADist($instance);
       	}
       	else {									#Prot sequence
       		$self->$_executeProtDist($instance);
       	}
	}
    
   	1;
