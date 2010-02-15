	##############################################
	## This class is a converter of formats of  ##
	## the module to turn entrances in the used ##
	## patterns								    ##
	##############################################

   	package Converter;
   	use strict;
   	use warnings;
   	use MainParameters;
        
   	##############################################
   	## formats convertion methods 	 		    ##
   	##############################################
	
	my $initChar = "ª";
		
	my $_fastaToPhylip  = sub {
		local $/;
        my $instance = Parameters::getInstance;
		$_ = shift;
		
		my @names;
		my @sequences;
		my $u = 0;
		while(s/>(.*)?[\n \t]+([^>]*)//){
#			my $name = "T$u";
			my $name = $initChar.(sprintf "%-10d",$u);
			# Se aki $name tiver tamanho > 10 naum se pode executar!!!
			# (isso acontece qnd o número de especies eh maior q 9.999.999)
#        	my $length = length($name);
#        	while($length++ < 10){
#        		$name .= " ";
#        	}
        	
        	$names[$u] = $1;
			$sequences[$u] .= $2;
			$sequences[$u] =~ s/\s//g;
			$sequences[$u++] = $name.$sequences[$u];
		}
				
		my $species = @sequences;		
		my $letters = $sequences[0];
		$letters =~ s/^.*?\s+//;
		$letters = length($letters);
						
		my $sequential = $species." ".$letters."\n";
		$sequential .= join "\n", @sequences;
		
		my $tempDir = $instance->parameter("TEMP");
		my $sequentialFile = $tempDir."/sequencial.txt";
		$instance->parameter("NAMES", \@names);
		$instance->parameter("LETTER", $letters);
		$instance->parameter("QSPEC", $species);
		$instance->parameter("INPUT", $sequentialFile);
		$instance->parameter("SEQUENTIAL", $sequential);
		
		open SEQUENCIAS, ">".$sequentialFile
			or die "ERROR: Unable open file: $sequentialFile.\n$!\n";
		print SEQUENCIAS $sequential;
		close SEQUENCIAS;
	};
	
	#tratar delecoes ou desconhecidos
	my $_nexusToPhylip  = sub {
        local $/;
        my $instance = Parameters::getInstance;
		$_ = shift;
		
       	# ignora comentarios
       	s/\[[\s\S]*?\]//g;
        
        # captura dados sobre as sequencias
        /ntax\s*=\s*(\d+)/i;	# quantidade de especies
        my $species = $1;
        
        /nchar\s*=\s*(\d+)/i;	# tamanho das sequencias
        my $letters = $1;
        
        /gap\s*=\s*(.)/i;		# delecoes ou caracteres inaplicaveis
        my $gap = $1;
        
        /missing\s*=\s*(.)/i;	# caracteres desconhecidos
        my $missing = $1;
        
        /matrix\s*([^;]*)/i;	# bloco de dados
        my $aux = $1;
        
        #$aux =~ s/\xd/\n/g;		# substitui \r por \n como separador de linha
        #$aux =~ s/$missing|$gap/-/g;	# substitui gaps e missings por dashes
        
        my @chars = split //,$aux;
        for my $i(0..$#chars){
        	$chars[$i] = '-' if($chars[$i] eq $missing || $chars[$i] eq $gap);
        }
        
        $aux = join '',@chars;
        @_ = split /\n[\n \t]*/, $aux;
		
        my @sequences;
        my @names;
        for my $i(0..$species-1) {
        	my $aux = shift; # @_
        	my $name = $initChar.(sprintf "%-9d",$i);
        	
        	$aux =~ s/^\s*'?(\S+)'?\s+/$name/;
        	$names[$i] = $1;
        	$sequences[$i] = $aux;
		}
		
       	while (@_) {
        	for my $i(0..$species-1) {
        		$sequences[$i] .= (split(/\s+/, shift @_))[1];
			}
		}
		
		my $sequential = $species." ".$letters."\n";
		$sequential .= join "\n", @sequences;
		
		my $tempDir = $instance->parameter("TEMP");
		my $sequentialFile = $tempDir."/sequencial.txt";
		$instance->parameter("NAMES", \@names);
		$instance->parameter("LETTER", $letters);
		$instance->parameter("QSPEC", $species);
		$instance->parameter("INPUT", $sequentialFile);
		$instance->parameter("SEQUENTIAL", $sequential);
		
		open SEQUENCIAS, '>'.$sequentialFile
			or die "ERROR: Unable open file: $sequentialFile.\n$!\n";
		print SEQUENCIAS $sequential."\n";
		close SEQUENCIAS;
	};
    
    my $_interleavedToSequential  = sub {
    	my $instance = Parameters::getInstance;
		
		# quebra o arquivo de sequencias em linhas
		$_ = shift;
		s/\n[\t ]+/\n/g;
		@_ = split /\n+/, $_;
		
		my $info = shift;
		$info =~ /\s*(\d+)\s+(\d+)/;
		my $species = $1;
		my $letters = $2;
		
		my @sequences;
		while (@_) {
			for my $i(0..$species-1) {
		 		$sequences[$i] .= shift @_;
		 	}
		}
		
		my @names;
		for my $i(0..$species-1){
			my $name = $initChar.(sprintf "%-10d",$i);
        	
        	$sequences[$i] =~ s/^\s*(\S+)\s+/$name/;
        	$names[$i] = $1;
		}
		
		my $sequential = $info."\n";
		$sequential .= join "\n", @sequences;
		
		my $tempDir = $instance->parameter("TEMP");
		my $sequentialFile = $tempDir."/sequencial.txt";
		$instance->parameter("NAMES", \@names);
		$instance->parameter("LETTER", $letters);
		$instance->parameter("QSPEC", $species);
		$instance->parameter("INPUT", $sequentialFile);
		$instance->parameter("SEQUENTIAL", $sequential);
		
		open SEQUENCIAS, ">".$sequentialFile
			or die "ERROR: Unable open file: $sequentialFile.\n$!\n";
		print SEQUENCIAS $sequential;
		close SEQUENCIAS;
	};
    
    sub FileConfigure{
    	local $/;
    	my $instance = Parameters::getInstance;
    	my $names = $instance->parameter("NAMES");
    	my $fileOut = $instance->parameter("OUTPUT");
    	
    	local @ARGV = ($fileOut);
    	no warnings;
    	($_ = <>) or die;
    	use warnings;
    	close ARGV;
    	for (my $i = $#{$names}; $i >= 0; $i--){
    		s/$initChar$i:/${$names}[$i]:/g;
    	}
		
		unlink ($fileOut);
		open OUTPUT, ">".$fileOut;
		print OUTPUT $_;
		close OUTPUT;
    }
    
    sub toSequential{
    	my $instance = Parameters::getInstance;
		local @ARGV = ($instance->parameter("INPUT"));
		
		local $/;
		$_ = <>;
		s/\xd/\n/g;		# substitui \r por \n como separador de linha
    	
    	if(/^#nexus/i) {
    		&$_nexusToPhylip($_);
    	}
    	elsif(/^>/) {
    		&$_fastaToPhylip($_);
    	}
    	elsif(/^\s*\d+\s+\d+/) {
    		&$_interleavedToSequential($_);
	    }
    	else {
    		die "ERROR: Input File -- Unknown format.";
	    }
    }

    1;
