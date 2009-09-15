	##################################################
	## here is the implementations than use the     ##
	## FastME program                               ##
	##################################################

    package FastME;
    use strict;
    use warnings;
	#use BasePackage::MainParameters;
	use MainAbstract;
	use File::Copy;
    use constant {
        GME   => 'O',
        BME   => 'b',
        FASTNNI  => 'O',
        BNNI  => 'b'
    };
    ##################################################
	## that class is responsible for maintaining	##
	## the code of execution of the FastME program	##
	##################################################

    our @ISA = ("AbstractMethod");
    
    my $swap = undef;
    my $build = undef;
    
    ## the object constructor						##
    
    sub new {
    	$swap = pop;
    	$build = pop;
    	
    	bless{};
    }
    
    ## implementation of the inherited method of	##
    ## the super class    			    			##

    sub executeMethod {
    	my $instance = Parameters::getInstance;
    	my $pwd = $instance->parameter("PWD");
    	my $tempDir = $instance->parameter("TEMP");
    	my $fileOut = $instance->parameter("OUTPUT");
    	my $matrix = $tempDir."/matrix";
    	system "$pwd/Exe/fastme -i $matrix -s $swap -b $build";
       	unlink "${matrix}_stat.txt";
       	move "${matrix}_tree.txt", $fileOut;
       	#print STDERR "fastme build: $build swap: $swap\n";
    }
    
    1;
