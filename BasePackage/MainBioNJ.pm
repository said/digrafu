	##################################################
	## that class is responsible for maintaining	##
	## the code of execution of the BioNJ program	##
	##################################################

    package BioNJ;
    use strict;
    use warnings;
	#use BasePackage::MainParameters;
	use MainAbstract;
    
    our @ISA = ("AbstractMethod");
    
    ##################################################
    ## the object constructor						##
    ##################################################
    
    sub new {
    	bless{};
    }
    
    ##################################################
    ## implementation of the inherited method of	##
    ## the super class    			    			##
    ##################################################

    sub executeMethod {
    	my $instance = Parameters::getInstance;
    	my $pwd = $instance->parameter("PWD");
    	my $tempDir = $instance->parameter("TEMP");
    	my $fileOut = $instance->parameter("OUTPUT");
    	my $matrix = $tempDir."/matrix";
       	system "$pwd/Exe/bionj $matrix $fileOut ";
       	#print STDERR "bionj\n";
    }
    
    1;
