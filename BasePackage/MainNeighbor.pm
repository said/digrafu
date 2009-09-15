	##################################################
	## that class is responsible for maintaining	##
	## the code of execution of the UPGMA program	##
	##################################################
	
	package Neighbor;
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
		open NJ, "| $pwd/Exe/upgma > /dev/null"
			  or die "ERROR: Unable to run upgma.\n$!\n";
		print NJ "$matrix\n2\n3\nY\n";
		close NJ;
		#print STDERR "upgma\n";
    	#system "$tempDir/upgma < $tempDir/parUpgma > $tempDir/logUpgma";
        
        unlink "./outfile";
	    move "./outtree", $fileOut;
    }
    
    1;
	
