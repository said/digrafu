	###################################################
	## that class is responsible for maintaining the ##
	## code of execution of the WEIGHBOR program	 ##
	###################################################
	
	package Weighbor;
    use strict;
    use warnings;
    use MainAbstract;
    
    our @ISA = ("AbstractMethod");
    
   	###################################################
    ## the object constructor						 ##
    ###################################################
    
    sub new {
    	bless{};
    }
    
    ###################################################
    ## implementation of the inherited method of the ##
    ## super class				    				 ##
    ###################################################

    sub executeMethod {
    	my $instance = Parameters::getInstance;
      	my $pwd = $instance->parameter("PWD");
    	my $tempDir = $instance->parameter("TEMP");
    	my $letters = $instance->parameter("LETTER");
    	my $fileOut = $instance->parameter("OUTPUT");
    	my $matrix = $tempDir."/matrix";
    	
     	system "$pwd/Exe/weighbor -L $letters -i $matrix -o $fileOut ";
     	#print STDERR "weighbor\n";
    }
    
    1;
	
