	##################################################
	## that class is responsible for maintaining	##
	## the code of execution of the UPGMA program	##
	##################################################
	
	package UPGMA;
    use strict;
    use warnings;
    #use BasePackage::MainParameters;
    use MainAbstract;
    use File::Copy;
    
    our @ISA = ("AbstractMethod");
    
    ##################################################
    ## the object constructor						##
    ##################################################
    
    sub new {
    	bless{};
    }
    
    ###################################################
	## private methods								 ##
	###################################################
	
	my $_getBranchLenth = sub {
		my $len = '';
		my $digit;
		my $array = shift;
		while(($digit = shift @{$array}) =~ /[0-9\.]/){
			$len .= $digit;
		}
		return $len;
	};
	
	my $_removeRoot = sub {    
	    local $/;
	    my $input = shift;
		my $output = shift;
		
		open ROOTED, $input;
		$_ = <ROOTED>;
		close ROOTED;
		
		my $pares = 0; # contador de parênteses
		my $tamAntigo = '';
		my $tamNovo;
		my $tail = '';
		
		s/\s+//g;
		my @chars = split //,$_;
		
		my $char;
		my $unrooted = shift @chars;
		
		do{
			$char = shift @chars;
			if($char eq '('){
				if($pares != 0){ # tirando o segundo "("
					$unrooted .= $char;
				}
				$pares++;
			} elsif($char eq ')'){
				$pares--;
				if($pares != 0){ # tirando o penúltimo ")"
					$unrooted .= $char;
				}
			} else {
				$unrooted .= $char;
			}
		}while($pares != 0);
		
		shift @chars; # descarta ':'
				
		# captura valor do antigo branch
		$tamAntigo = &$_getBranchLenth(\@chars);
		
		$unrooted .= ',';	# salva ','
		
		while(($char = pop @chars) ne ':'){
			$tail = $char.$tail; 
		}
		
		$unrooted .= join('',@chars);
		$unrooted .= ':';
		
		$tail =~ /([\d\.]+)/;
		
		$tamNovo = $tamAntigo + $1;
		
		$unrooted .= $tamNovo.");";
		
		open UNROOTED,">$output" or die $!;
		print UNROOTED $unrooted;
		close UNROOTED;
	};
	    
    ##################################################
    ## implementation of the inherited method of	##
    ## the super class						    	##
    ##################################################

   	sub executeMethod {
		my $instance = Parameters::getInstance;
	    my $pwd = $instance->parameter("PWD");
	    my $tempDir = $instance->parameter("TEMP");
    	my $fileOut = $instance->parameter("OUTPUT");
	    my $matrix = $tempDir."/matrix";
    	
		#open UPGMA, ">$tempDir/parUpgma"
		#	  or die "ERROR: Unable to open file: $tempDir/parUpgma.\n$!\n";
		#print UPGMA "$matrix\nN\n2\n3\nY\n";
		#close UPGMA;
		
		#chdir "$tempDir/";
		copy "$pwd/Exe/upgma", "$tempDir/";
		chmod 0755, "$tempDir/upgma";
		open UPGMA, "| $pwd/Exe/upgma > /dev/null"
			  or die "ERROR: Unable to run upgma.\n$!\n";
		print UPGMA "$matrix\nN\n2\n3\nY\n";
		close UPGMA;
		#print STDERR "upgma\n";
    	#system "$tempDir/upgma < $tempDir/parUpgma > $tempDir/logUpgma";
        
        unlink "./outfile";
        &$_removeRoot("./outtree",$fileOut);
	    #move "./outtree", $fileOut;
    }
    
    1;
	
