	##################################################
	## this class implements the methods need to    ##
	## define the model JC69                        ##
	##################################################

    package JC69;
    use strict;
    use warnings;
	use MainParameters;
	use MainAbstract;
	use MainModel;
	use MainUPGMA;
	use MainNeighbor;
	use MainBioNJ;
	use MainWeighbor;
	use MainFastME;
	
    our @ISA = ("Model");
    
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

    sub chooseMethod {
    	my $instance = Parameters::getInstance;
    	my $preference = $instance->parameter('PREFERENCE');
    	my $md = $instance->parameter('LDIFFERENCE');
    	
    	if($preference eq 'ta'){
    		if($md <= 0.1){
    		   	return new Neighbor;
    		}
    		elsif($md > 0.15 and $md <= 0.2){
    		   	return new BioNJ;
    		}
    		elsif(($md > 0.1 and $md <= 0.15) or
    			  ($md > 0.3 and $md <= 0.4) or
    			  ($md > 0.45 and $md <= 0.5) or
    			  ($md > 0.55 and $md <= 0.6) or
    		      ($md > 0.65 and $md <= 0.7)){
    		   	return FastME::new(FastME::GME, FastME::BNNI);
    		}
    		else{
    			return FastME::new(FastME::BME, FastME::BNNI);
    		}
    	}
    	else{
    		if(($md > 0.1 and $md <= 0.15) or
    		   ($md > 0.35 and $md <= 0.4)){
    		   	return FastME::new(FastME::GME, FastME::BNNI);
    		}
    		elsif(($md > 0.25 and $md <= 0.3) or
    		      ($md > 0.5 and $md <= 0.55)){
    		   	return FastME::new(FastME::BME, FastME::BNNI);
    		}
    		else{
    			return new Weighbor;
    		}
    	}
    	
#    	if($preference eq 'ta'){
#			if($md <= 0.1){
#				return new Neighbor;
#			}
#			else{
#				return new BioNJ;
#			}
#		}
#		else{
#			return new Weighbor;
#		}
    }
    
    1;
